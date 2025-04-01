from django.urls import path

from . import views

urlpatterns = [
    # ex: /users/
    path("", views.index, name="index"),
    # ex: /users/5/
    path("<int:user_id>/", views.detail, name="detail"),
]
