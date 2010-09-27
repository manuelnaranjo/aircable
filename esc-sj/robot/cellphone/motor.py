class Robot(object):
    sock = None

    def __init__(self, sock):
        self.sock = sock

    def M0_stop(self):
        return '\x88\x00' # M0 stop

    def M0_forward(self):
        return '\x89\x7f'# M0 full steam ahead

    def M0_backward(self):
        return '\x8B\x7f'# M0 full steam backward

    def M1_stop(self):
        return '\x8C\x00' 

    def M1_forward(self):
        return '\x8D\x7f'

    def M1_backward(self):
        return '\x8F\x7f'

    def __send_command(self, c1, c2):
        self.sock.send('%s%s' % (c1, c2))

    def stop(self):
        self.__send_command(self.M0_stop(), self.M1_stop())

    def forward(self):
        self.__send_command(self.M0_forward(), self.M1_forward())

    def backward(self):
        self.__send_command(self.M0_backward(), self.M1_backward())

    def right(self):
        self.__send_command(self.M1_forward(), self.M0_backward())

    def left(self):
        self.__send_command(self.M0_forward(), self.M1_backward())

def test(target):
    import btsocket as socket
    import e32
    # Bluetooth connection
    sock=socket.socket(socket.AF_BT,socket.SOCK_STREAM)

    print "Connecting to "+str(target)+"...",
    sock.connect((target, 1))
    print "OK."
    r = Robot(sock)
    r.forward()
    e32.ao_sleep(2)
    r.backward()
    e32.ao_sleep(2)
    r.left()
    e32.ao_sleep(2)
    r.right()
    e32.ao_sleep(2)
    r.stop()
    return r
