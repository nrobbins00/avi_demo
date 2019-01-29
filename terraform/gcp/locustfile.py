import os
import string
import random
from locust import HttpLocust, TaskSet, task

class MyTaskSet(TaskSet):
    @task(1000)
    def index(self):
        response = self.client.get("/")

    # This task will 15 times for every 1000 runs of the above task
    @task(15)
    def error(self):
        self.client.get("/ohnomissing")

    # This task will run once for every 1000 runs of the above task
    @task(1)
    def filedownload(self):
        self.client.get("/100k.dat")

class MyLocust(HttpLocust):
    host = os.getenv('TARGET_URL', "http://localhost")
    task_set = MyTaskSet
    min_wait = 45
    max_wait = 50