class APIException(Exception):
    """docstring for APIException"""
    def __init__(self, Value):
        self.Value = Value

    def __str__(self):
        return repr(self.Value)
