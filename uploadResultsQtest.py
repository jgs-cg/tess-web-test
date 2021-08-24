# importing the requests library
import requests
import json
import os

filePath = os.environ['reportFilePath']
fileName = os.environ['reportFileName']
projectId = os.environ['projectId']
aut = os.environ['aut']
atmId =os.environ['atmId']
cycleId =os.environ['cycleId']
requestedParser =os.environ['requestedParser']
contactInitials = os.environ['contactInitials']
env = os.environ['environment']
url = os.environ['WEB_HOOK']

with open(filePath + "/" + fileName, "r") as read_file:
     data = read_file.read()

payload = {"result": data ,
           "testCycleName": "",
           "projectId": projectId,
           "aut": aut,
           "atmId" : atmId,
           "cycleId" : cycleId,
           "requestedParser" : requestedParser,
           "jobUrl" : "jobUrl",
           "contactInitials" : contactInitials,
           "modulePath": env
           }

headerInfo = {'Content-Type' : 'application/json'}

response= requests.post(url=url,data=json.dumps(payload), headers=headerInfo,verify=False)
print(response)