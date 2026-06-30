import urllib.request
import json

url = "https://neon.new/api/v1/database"
data = json.dumps({"ref": "freelancemada"}).encode('utf-8')
req = urllib.request.Request(
    url, 
    data=data, 
    headers={'Content-Type': 'application/json'}
)

try:
    print("Calling neon.new API...")
    with urllib.request.urlopen(req) as response:
        res = json.loads(response.read().decode('utf-8'))
        print(json.dumps(res, indent=2))
        
        # Write credentials to database_credentials.txt
        with open('database_credentials.txt', 'w', encoding='utf-8') as f:
            f.write(json.dumps(res, indent=2))
        print("Success! Saved to database_credentials.txt")
except Exception as e:
    print("Error:", e)
