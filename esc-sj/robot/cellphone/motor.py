class Robot(object):
    sock = None

    def __init__(self, sock):
        self.sock = sock
        self.sock.setblocking(False)

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

    def stop(self):
        self.sock.send(self.M0_stop()+self.M1_stop())

    def forward(self):
        self.sock.send(self.M0_forward()+self.M1_forward())

    def backward(self):
        self.sock.send(self.M0_backward()+self.M1_backward())

    def right(self):
        self.sock.send(self.M1_forward()+self.M0_backward())

    def left(self):
        self.sock.send(self.M0_forward()+self.M1_backward())


