from requests.auth import HTTPBasicAuth
import requests
import argparse
import urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)


class SIEM:
    def __init__(self, host, api_port, username, password, index) -> None:
        self.host = host
        self.api_port = api_port
        self.username = username
        self.password = password
        self.index = index


##############################################################################################################################################
# Create Splunk index
##############################################################################################################################################
def splunk_get_session_key(siem) -> str:
    """
    Authenticate to Splunk and get a session key
    """
    return requests.get(
        url = f"https://{siem.host}:{siem.api_port}/servicesNS/admin/search/auth/login", 
        data={'username': siem.username,'password': siem.password, "output_mode": "json"}, 
        verify=False
    ).json()['sessionKey']

def splunk_index_list(siem, splunk_session_key):
    """
    Return a list of splunk indexes
    """
    r = requests.get(
        url = f"https://{siem.host}:{siem.api_port}/services/data/indexes?datatype=event",
        headers = { 'Authorization': (f"Splunk {splunk_session_key}")},
        data={"output_mode": "json"},
        verify=False
    ).json()
    return [ entry['name'] for entry in r['entry'] ]

def create_splunk_index(siem):
    # Authenticate to Splunk
    splunk_session_key = splunk_get_session_key(siem)

    # get a list of indexes
    index_list = splunk_index_list(siem, splunk_session_key)

    # Create inde
    if siem.index not in index_list:
        payload = {
            "name": siem.index,
            "datatype": "event",
            "output_mode": "json"
        }

        r = requests.post(
            url = f"https://{siem.host}:{siem.api_port}/servicesNS/admin/search/data/indexes",
            headers = { 'Authorization': (f"Splunk {splunk_session_key}")},
            data=payload,
            verify=False
        ).json()

        print (f"[+] - Splunk index created {siem.index}")
    else:
        print (f"[*] - Splunk index {siem.index} already exists")

##############################################################################################################################################
# Create Splunk HEC token
##############################################################################################################################################
#def create_splunk_hec_token():

##############################################################################################################################################
# Create Graylog index
##############################################################################################################################################

##############################################################################################################################################
# Create Graylog stream
##############################################################################################################################################

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--host', type=str, required=True, help='Specify server FQDN or IP address')
    parser.add_argument('--api_port', type=int, default=443, help='WebGUI port')
    parser.add_argument('--index', type=str, required=True, help='Name of index to create')
    parser.add_argument('--platform', type=str, required=True, choices=['elastic','graylog','splunk'], help='Specify SIEM platform')
    parser.add_argument('--siem_username', type=str, default='admin', help='SIEM username')
    parser.add_argument('--siem_password', type=str, default='Changeme123!', help='SIEM password')
    args = parser.parse_args()

    # Create SIEM object
    siem = SIEM(args.host, args.api_port, args.siem_username, args.siem_password, args.index)


    if args.platform == 'splunk':
        create_splunk_index(siem)
    else:
        print ("Failed")