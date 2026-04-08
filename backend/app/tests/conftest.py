import os
import uuid

import pytest
from fastapi.testclient import TestClient

os.environ.setdefault("SECRET_KEY", "test")
os.environ.setdefault("DATABASE_URL", "postgresql+psycopg2://user:pass@localhost/db")

from app.core.database import get_db
from app.core.dependencies import get_current_user
from app.main import app


class FakeQuery:
    def __init__(self, items=None):
        self._items = items or []

    def filter(self, *args, **kwargs):
        return self

    def count(self):
        return len(self._items)

    def order_by(self, *args, **kwargs):
        return self

    def offset(self, *args, **kwargs):
        return self

    def limit(self, *args, **kwargs):
        return self

    def all(self):
        return self._items

    def first(self):
        return self._items[0] if self._items else None


class FakeSession:
    def query(self, *args, **kwargs):
        return FakeQuery([])

    def close(self):
        pass


class FakeUser:
    def __init__(self):
        self.id = uuid.uuid4()
        self.clinic_id = uuid.uuid4()
        self.role = "admin"


@pytest.fixture()
def client():
    app.dependency_overrides[get_db] = lambda: FakeSession()
    app.dependency_overrides[get_current_user] = lambda: FakeUser()
    with TestClient(app) as c:
        yield c
    app.dependency_overrides = {}
