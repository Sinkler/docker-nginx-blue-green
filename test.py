import httplib


def get_status_code(host, path="/"):
    try:
        conn = httplib.HTTPConnection(host)
        conn.request('HEAD', path)
        return conn.getresponse().status
    except StandardError:
        return None


while True:
    print get_status_code('localhost')
