__all__ = [
    "_printEnv",
    "_printDict",
    "_dump"
]

print(f"Custom Startup Defined Functions:\n{__all__}")


#### Set custom REPL options ###################################################
import sys
# Set the primary prompt to bright green
sys.ps1 = '\033[92m>>> \033[0m'
# Set the secondary prompt to yellow
sys.ps2 = '\033[1;38;5;226m... \033[0m'
################################################################################


def _printEnv(var=None):
    """Print the value of the specified environment variable.

    Args:
        var (str, optional): The name of the environment variable to print. If None, prints all environment variables.

    Returns:
        None

    """
    import os
    if var:
        [print(v) for v in os.getenv(var, "").split(os.pathsep)]
    else:
        _printDict(os.environ)


def _printDict(pydict):
    """Sort the dictionary keys and print {key} = {value} for each.

    Args:
        pydict (dict)

    Returns:
        None

    """
    [print(f"{key} = {pydict.get(key)}") for key in sorted(pydict.keys())]


def _dump(obj, values=False):
    """Prints out a sorted list of the dir of the supplied object.

    Args:
        obj (Object): Any Python object compatible with dir
        values (bool, optional): If true will print <attr> = <attr value>

    """
    if values:
        [print(f"{attr} = {getattr(obj, attr)}") for attr in sorted(dir(obj))]
    else:
        [print(attr) for attr in sorted(dir(obj))]
