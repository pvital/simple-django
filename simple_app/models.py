# Assisted by watsonx Code Assistant
from django.db import models


class User(models.Model):
    id = models.AutoField(primary_key=True)
    email = models.EmailField(unique=True)
    first_name = models.CharField(max_length=50)
    last_name = models.CharField(max_length=50)
    avatar = models.URLField()

    def __str__(self):
        return f"{self.first_name} {self.last_name} ({self.email})"
