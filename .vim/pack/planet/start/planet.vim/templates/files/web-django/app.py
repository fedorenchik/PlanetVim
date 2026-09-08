"""Install Django, then run: python3 app.py runserver 127.0.0.1:8000."""
import os
import sys
from django.conf import settings
from django.http import HttpResponse
from django.urls import path
settings.configure(SECRET_KEY=os.environ.get('DJANGO_SECRET_KEY', 'local-development-key'), ROOT_URLCONF=__name__, ALLOWED_HOSTS=['127.0.0.1', 'localhost'])
def index(request):
    return HttpResponse('Hello from PlanetVim', content_type='text/plain')
urlpatterns = [path('', index)]
if __name__ == '__main__':
    from django.core.management import execute_from_command_line
    execute_from_command_line(sys.argv)
