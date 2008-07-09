from obex_server import  MessageServer
from obex_message import ObexMessage

DEBUG = 2
""" 1 login information
    2 debuggin information
"""
    
def debug( text , level = 2):
    """ Internal debugging function """
    if level <= DEBUG :
	print text
		    