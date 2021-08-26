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
url = "https://qtest.cguser.capgroup.com:4080/webhook/ad6396c2-c0ca-4123-860a-681f47b56af1"
BuildNum = os.environ['CODEBUILD_BUILD_NUMBER']


print("BuildNum is", BuildNum)
print("projectId is", projectId)
print("aut is", aut)
print("Filepath and name" , filePath + "/" + fileName)
with open(filePath + "/" + fileName, "r") as read_file:
     data = read_file.read()

print("File read is ", data)
payload = {    
               "result": data ,
               "testCycleName": "BuildNum#" + BuildNum,
               "projectId": projectId,
               "aut": aut,
                "atmId" : atmId,
               "cycleId" : cycleId,
               "requestedParser" : requestedParser,
               "jobUrl" : "CodeBuild",
               "contactInitials" : contactInitials
               "parseXml" : "false"
           }

headerInfo = {'Content-Type' : 'application/json'}

response= requests.post(url=url,data=json.dumps(payload), headers=headerInfo,verify=False)
print(response)
