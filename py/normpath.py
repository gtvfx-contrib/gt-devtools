__doc__ = """ This is a class for normalizing a path to either
Windows or Unix.

You can supply a path yourself or it will use the text in your
Windows clipboard.

This uses the click framework to create a command line utility

Argumentss:
    --path (str):
        * The path to normalize
        * If not supplied the tool grabs the string from the 
        Windwows clipboard

Flags:
    --unix
        * normalizes the path to unix

    --force
        * skips path validation and simply normalizes the slash characters

"""

import os
import win32clipboard
import click


class NormPath(object):
    """Normalizes the os.separator character in the clipboard string

    see module __doc__ for command line usage.

    Arguments;
        path (str)
        force (bool, optional): if true will skip path validation and 
            simply normalizes the clipboard string.
        uxix (bool, optional): if true will normalize the path as a Unix path

    """
    def __init__(self, path, force=None, unix=None):
        super(NormPath, self).__init__()

        self.path = path
        self.force = force
        self.unix = unix

    @property
    def path(self):
        """(str): Path to operate on"""
        return self._path or self.get_clipboard()

    @path.setter
    def path(self, path):
        self._path = path

    def validate_path(self, path):
        """Attempts to validate the inputed string as a path
        
        Arguments:
            path (str)

        Returns:
            (bool): True if supplied path is valid
        
        """
        if self.force:
            return True

        out = False

        try:
            if not os.path.isfile(path) or not os.path.isdir(path):
                out = True
        except:
            pass

        return out

    def get_clipboard(self):
        """Returns the clipboard string

        if not self.force:
            attempts to validate the clipboard text as a path

        Will remove double quatations from the string
        
        Returns:
            (str)

        Raises:
            (ValueError): if the clipboard string fails the 
                validate_path method.

        """
        win32clipboard.OpenClipboard()
        data = win32clipboard.GetClipboardData()
        win32clipboard.CloseClipboard()

        data = data.replace('"', '')

        if not self.validate_path(data):
            raise ValueError('You do not have a valid path in your clipboard') 

        return data

    def set_clipboard(self, path):
        """Sets the Windows clipboard text to the inputed path string

        Arguments:
            path (str)

        Returns:
            (void)

        """
        win32clipboard.OpenClipboard()
        win32clipboard.EmptyClipboard()
        win32clipboard.SetClipboardText(path)
        win32clipboard.CloseClipboard()

    def to_windows(self):
        """Normalizes the value in self.path to Windows 
        
        Sets the Windows clipboard text to the normalized string

        Returns:
            (str)

        """
        nText = self.path.replace('/','\\')
        self.set_clipboard(nText)
        return nText

    def to_unix(self, path=None):
        """Normalizes the value in self.path to Unix 
        
        Sets the Windows clipboard text to the normalized string

        Arguments:
            path (str, optional): If unsupplied will call self.get_clipboard()

        Returns:
            (str)

        See also:
            self.get_clipboard
            self.set_clipboard
            
        """
        nText = self.path.replace('\\','/')
        self.set_clipboard(nText)
        return nText

    def _execute(self):
        """Main logic

        Returns:
            (void)

        See Also:
            to_unix()
            to_windows()

        """
        if self.unix:
            self.to_unix()
        else:
            self.to_windows()



@click.command()
@click.option('--unix', is_flag=True)
@click.option('--force', is_flag=True)
@click.option('--path', default=None)
def main(path, force, unix):
    """This is the main logic executed by the tool"""
    normPath = NormPath(path, force, unix)
    normPath._execute()


if __name__ == "__main__":
   main()
   