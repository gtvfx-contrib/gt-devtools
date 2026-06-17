__all__ = [
    "_dump",
    "_inspect",
    "_printDict",
    "_printEnv",
]

print(f"Custom Startup Defined Functions:\n{__all__}")

# ------------------------------------------------------------------------------
# region: REPL Customization
# ------------------------------------------------------------------------------

#### Set custom REPL options ###################################################
import sys
# Set the primary prompt to bright green
sys.ps1 = '\033[92m>>> \033[0m'
# Set the secondary prompt to yellow
sys.ps2 = '\033[1;38;5;226m... \033[0m'
################################################################################

# endregion

# ------------------------------------------------------------------------------
# region: Available functions
# ------------------------------------------------------------------------------

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


def _inspect(obj):
    """Prints, in detail, information about the supplied object

    Arguments:
        obj (Object)

    Returns:
        None

    """
    import inspect
    import reprlib

    print("Type")
    print("====")
    print(type(obj))
    print()

    print("Documentation")
    print("=============")
    print(inspect.getdoc(obj))
    print()

    print("Attributes")
    print("==========")
    all_attr_names = set(dir(obj))
    method_names = set(filter(lambda attr_name: callable(getattr(obj, attr_name)), all_attr_names))
    assert len(method_names) <= len(all_attr_names),\
           "len(method_names): {}, len(all_attr_names): {}".format(len(method_names), len(all_attr_names))
    attr_names = all_attr_names - method_names # type: ignore
    attr_names_and_values = [(name, reprlib.repr(getattr(obj, name))) for name in sorted(attr_names)]
    _printTable(attr_names_and_values, "Name", "Value")
    print()

    print("Methods")
    print("=======")
    methods = (getattr(obj, method_name) for method_name in sorted(method_names)) # type: ignore
    method_names_and_doc = [(_fullSig(method), _briefDoc(method)) for method in methods]
    _printTable(method_names_and_doc, "Name", "Description")
    print()

# endregion

# ------------------------------------------------------------------------------
# region: Helper functions
# ------------------------------------------------------------------------------

def _fullSig(method):
    """Gets the inspect.signature of the supplied method
    
    Returns a predefined string if unable to get a valid signature

    Arguments:
        method (function)

    Returns
        (str)

    """
    import inspect
    try:
        return method.__name__ + str(inspect.signature(method))
    except ValueError:
        return method.__name__ + '(...)'


def _briefDoc(obj):
    """Returns the first line of the doc string of the supplied object

    Returns an empty string if object has no doc string

    Arguments:
        obj (Object)

    Returns:
        (str)

    """
    doc = obj.__doc__
    if doc is not None:
        lines = doc.splitlines()
        if len(lines) > 0:
            return lines[0]
    return ''


def _printTable(rows_of_columns, *headers):
    """Format the supplied lists in a table format

    Arguments:
        rows_of_columns (list of str)
        *headers (str)

    Returns:
        None

    """
    import itertools

    num_columns = len(rows_of_columns[0])
    num_headers = len(headers)
    if len(headers) != num_columns:
        raise TypeError("Expected {} header arguments, "
                        "got {}".format(num_columns, num_headers))
    rows_of_columns_with_header = itertools.chain([headers], rows_of_columns)
    columns_of_rows = list(zip(*rows_of_columns_with_header))
    column_widths = [max(map(len, column)) for column in columns_of_rows]
    column_specs = ('{{:{w}}}'.format(w=width) for width in column_widths)
    format_spec = ' '.join(column_specs)
    print(format_spec.format(*headers))
    rules = ('-' * width for width in column_widths)
    print(format_spec.format(*rules))
    for row in rows_of_columns:
        print(format_spec.format(*row))

# endregion
