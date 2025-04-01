import requests
from django.http import Http404
from django.shortcuts import get_object_or_404, render

from .models import User


def _request_users():
    resp = requests.get("https://reqres.in/api/users").json()
    return resp["data"]


def _create_user(user_data):
    user = User(
        id=user_data.get("id"),
        email=user_data.get("email"),
        first_name=user_data.get("first_name"),
        last_name=user_data.get("last_name"),
        avatar=user_data.get("avatar"),
    )
    user.save()


def _create_users():
    for user in _request_users():
        _create_user(user)


def index(request):
    users_list = User.objects.all()
    if len(users_list) == 0:
        try:
            _create_users()
        except Exception:
            raise Http404("No users found.")
        else:
            users_list = User.objects.all()

    context = {
        "users_list": users_list,
    }
    return render(request, "users/index.html", context)


def detail(request, user_id):
    user = get_object_or_404(User, pk=user_id)
    return render(request, "users/detail.html", {"user": user})
