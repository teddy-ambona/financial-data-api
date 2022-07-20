def test_healthcheck(client):
    r = client.get('/_healthcheck')
    assert r.status_code == 200
