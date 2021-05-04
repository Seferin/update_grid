import os # to access credentials stored as environment variables and create local cache directory if needed
import requests # for HTML Post and Get methods
import json # To parse response payloads
import pandas as pd # For consolidating results into a dataframe
import zipfile

def ensure_local_folder(path_folder):
    ''' 
    To check for existence of named local folder and create folder if absent
    
    Inputs ---
    path_folder   str   name of folder required
    
    Outputs ---
    None
    ''' 
    
    # Test inputs
    if type(path_folder) is not str:
        raise ValueError('path_folder supplied to ensure_local_folder is not string')
    
    # Test for path folder
    if not os.path.isdir(path_folder):
        print('Creating local folder:\n ' + path_folder + '\nIn:\n ' + os.getcwd())
        os.mkdir(path_folder)


def update_grid(path_data = "./data/"):
    ensure_local_folder(path_data)
    
    # Check release details
    res_details = requests.get("https://api.figshare.com/v2/collections/3812929/articles")
    if res_details.status_code != 200:
        value_error_msg = ''.join(('\nRequest to update_grid has failed to retrieve release details from figshare with status:\n',
                                   str(res_details.status_code)))
        raise ValueError(value_error_msg)

    details_df = pd.DataFrame(json.loads(res_details.text))
    max_date = details_df["published_date"].max()
    release_df = details_df.loc[details_df["published_date"]==max_date, ['url', 'published_date']]

    # Get most recent filename and download link
    res_files = requests.get(release_df['url'][0])
    if res_files.status_code != 200:
        value_error_msg = ''.join(('\nRequest to update_grid has failed to retrieve file details from figshare with status:\n',
                                   str(res_files.status_code)))
        raise ValueError(value_error_msg)
    res_files = json.loads(res_files.text).get('files')[0]

    # Download release if file does not exist in path_data
    if os.path.exists(path_data + "download_log.txt"):
        if res_files.get('name') == open(path_data + 'download_log.txt', 'r').read().split('\n', 1)[0]:
            print("Local GRID data cache already latest release")

            # Exit update_grid without further side effects
            return

    # Download release 
    print("Downloading latest GRID release ("+ max_date + ") to " + path_data)
    res = requests.get(res_files.get('download_url'), allow_redirects=True)
    open(path_data + res_files.get('name'), 'wb').write(res.content)

    # Unzip release
    with zipfile.ZipFile(path_data + res_files.get('name'), 'r') as zip_ref:
        zip_ref.extractall(path_data)

    # Log release via release file name
    open(path_data + "download_log.txt", 'w').write(res_files.get('name') + '\n')
    
    # Tidy up
    if os.path.exists(path_data + res_files.get('name')):
        os.remove(path_data + res_files.get('name'))


if __name__ == "__main__":
    # execute only if run as a script
    main()