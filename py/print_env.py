"""Prints a '{key} = {value}' formatted string for each item in os.environ."""

def main():
    import os
    keyList = sorted(os.environ.keys())
    for key in keyList:
        print('{} = {}\n'.format(key, os.environ.get(key)))


if __name__ == '__main__':
    main()
    