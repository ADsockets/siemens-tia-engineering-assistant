"""Exercise the help probe against an owned loopback HTTP server, without TIA."""

import argparse
import json
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
import socket
import subprocess
import threading
import unittest


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        code = 404 if self.path.startswith('/missing') else 200
        self.send_response(code)
        self.send_header('Content-Type', 'text/plain')
        self.end_headers()
        self.wfile.write(b'probe test')

    def log_message(self, *_args):
        pass


class ProbeTests(unittest.TestCase):
    shell = 'powershell.exe'

    @classmethod
    def setUpClass(cls):
        cls.server = ThreadingHTTPServer(('127.0.0.1', 0), Handler)
        cls.thread = threading.Thread(target=cls.server.serve_forever, daemon=True)
        cls.thread.start()
        cls.base = f'http://127.0.0.1:{cls.server.server_port}'
        cls.script = Path(__file__).resolve().parents[1] / 'skill' / 'siemens-tia-engineering-assistant' / 'scripts' / 'probe-help-viewer.ps1'

    @classmethod
    def tearDownClass(cls):
        cls.server.shutdown()
        cls.server.server_close()
        cls.thread.join(timeout=5)

    def probe(self, url):
        return subprocess.run(
            [self.shell, '-NoProfile', '-NonInteractive', '-ExecutionPolicy', 'Bypass', '-File', str(self.script),
             '-BaseUrl', url, '-TimeoutSeconds', '2'],
            capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=20,
        )

    def test_success_redacts_query_and_fragment(self):
        marker = 'probe-' + 'private-value'
        result = self.probe(self.base + '/help?document=' + marker + '#' + marker)
        self.assertEqual(result.returncode, 0, result.stderr)
        data = json.loads(result.stdout)
        self.assertTrue(data['available'])
        self.assertTrue(data['reachable'])
        self.assertEqual(data['status_code'], 200)
        self.assertEqual(data['url'], self.base + '/help')
        self.assertNotIn(marker, result.stdout + result.stderr)

    def test_http_error_is_reachable_and_redacted(self):
        marker = 'probe-' + 'private-value'
        result = self.probe(self.base + '/missing?document=' + marker)
        self.assertEqual(result.returncode, 1)
        data = json.loads(result.stdout)
        self.assertFalse(data['available'])
        self.assertTrue(data['reachable'])
        self.assertEqual(data['status_code'], 404)
        self.assertEqual(data['error'], 'http_error')
        self.assertNotIn(marker, result.stdout + result.stderr)

    def test_unreachable_service_has_no_http_status(self):
        with socket.socket() as reserved:
            reserved.bind(('127.0.0.1', 0))
            result = self.probe(f'http://127.0.0.1:{reserved.getsockname()[1]}/')
        self.assertEqual(result.returncode, 1)
        data = json.loads(result.stdout)
        self.assertFalse(data['available'])
        self.assertFalse(data['reachable'])
        self.assertIsNone(data['status_code'])

    def test_userinfo_is_rejected_without_echoing_it(self):
        marker = 'probe-' + 'private-value'
        result = self.probe(self.base.replace('http://', 'http://reader:' + marker + '@'))
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn(marker, result.stdout + result.stderr)

    def test_non_http_scheme_is_rejected(self):
        result = self.probe('file:///not-a-service')
        self.assertNotEqual(result.returncode, 0)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--shell', default='powershell.exe')
    args, remaining = parser.parse_known_args()
    ProbeTests.shell = args.shell
    unittest.main(argv=['test-help-probe.py', *remaining])
