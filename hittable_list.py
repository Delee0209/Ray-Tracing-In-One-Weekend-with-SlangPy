import slangpy as spy
import numpy as np

class hittable_list:
    def __init__(self):
        self.objects = []
        self.appearances = []

    def add_material(self, appearance):
        mat = len(self.appearances)
        self.appearances.append(appearance)
        return mat

    def add_hittable(self, obj):
        self.objects.append(obj)

    def prepare(self, device: spy.Device):
        # Prepare hittable data
        object_data = np.frombuffer(b"".join(object.pack() for object in self.objects), dtype = np.uint8).flatten()
        self.object_buffer = device.create_buffer(usage = spy.BufferUsage.shader_resource,
                                                  label = "object_buffer",
                                                  data = object_data)
        # Prepare material data
        appearance_data = np.frombuffer(b"".join(appearance.pack() for appearance in self.appearances), dtype = np.uint8).flatten()
        self.appearance_buffer = device.create_buffer(usage = spy.BufferUsage.shader_resource,
                                                      label = "appearance_buffer",
                                                      data = appearance_data)
        
    def bind(self):
        uniform = {'object_count':  len(self.objects),
                   'objects':       self.object_buffer,
                   'appearances':   self.appearance_buffer}
        return uniform