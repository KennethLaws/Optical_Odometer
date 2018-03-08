"""
The base class of all GPS parsers in the module
"""

__author__ = 'Tom Slankard <tom.slankard@here.com>'

class Parser(object):
    """
    The base class of all GPS parsers in the module
    """
    def __init__(self):
        self.debug = False

    def log(self, message):
        """
        Log a message
        """
        if self.debug:
            print message

