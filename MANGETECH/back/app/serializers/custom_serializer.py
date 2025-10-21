class ReadWriteSerializer(object):
    read_serializer_class = None
    write_serializer_class = None

    def get_read_serializer_class(self):
        return self.read_serializer_class
    
    def get_write_serializer_class(self):
        return self.write_serializer_class
    
    def get_serializer_class(self):
        if self.action in ['create','update',
                           'partial_update','destroy']:
            return self.get_write_serializer_class()
        return self.get_read_serializer_class()
        