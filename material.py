import struct

class material:
    def __init__(self):
        self.padding = 0.0
    
    def pack(self):
        pass

class lambertian(material):
    def __init__(self, albedo):
        super().__init__()
        self.albedo = albedo

    def pack(self):
        return struct.pack("Iffff",
                           0, # material type == 0
                           self.albedo[0], self.albedo[1], self.albedo[2],
                           self.padding)

class metal(material):
    def __init__(self, albedo, fuzz):
        super().__init__()
        self.albedo = albedo
        self.fuzz = fuzz

    def pack(self):
        return struct.pack("Iffff",
                           1, # material type == 1
                           self.albedo[0], self.albedo[1], self.albedo[2],
                           self.fuzz)

class dielectric(material):
    def __init__(self, refraction_index):
        super().__init__()
        self.refraction_index = refraction_index

    def pack(self):
        return struct.pack("Iffff",
                           2, # material type == 2
                           self.padding, self.padding, self.padding,
                           self.refraction_index)