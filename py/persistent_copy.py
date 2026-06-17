import os
import re
import shutil

import click


@click.command(name='persistent_copy')
@click.argument('source', default=None, required=True)
@click.argument('dest', default=None, required=True)
def main(source, dest):
    """Relentlessly attempts to copy all contents from source to destination.add()
    
    Performed within a while loop that tests the contents of source against the
    contents of dest.

    Args:
        source (str): Source directory
        dest (str): Destination directory
        
    """
    source_contents = get_folder_contents(source)
    # dest_contents = get_folder_contents(dest)
    
    # while len(source_contents) != len(dest_contents):
    #     print(f"source_contents: {len(source_contents)} | dest_contents: {len(dest_contents)}")
    for filepath in source_contents:
        dest_filepath = get_dest_sub_folder(filepath, source, dest)
        # print(dest_filepath)
        # return
        if not os.path.exists(dest_filepath):
            print(dest_filepath)
            ensure_directory(os.path.dirname(dest_filepath))
            shutil.copy2(filepath, dest_filepath)


def get_dest_sub_folder(filepath, source, dest):
    """_summary_

    Args:
        filepath (_type_): _description_
        dest (_type_): _description_
    
    """
    # Strip off the extra text on the folders that lists the number of items.
    pattern = r".*?\((.*)\).*"
    match = re.search(pattern, filepath)
    if match:
        filepath = filepath.replace(" ({})".format(match.group(1)), "")
    
    return filepath.replace(source, dest+"\\")


def ensure_directory(folder):
    """_summary_

    Args:
        folder (_type_): _description_
    
    """
    return os.makedirs(folder, exist_ok=True)
    
    
def get_folder_contents(folder):
    """_summary_

    Args:
        folder (_type_): _description_
        
    """
    return [os.path.normpath(os.path.join(dp, f)) for dp, _, filenames in os.walk(folder) for f in filenames]


if __name__ == "__main__":
    main()
