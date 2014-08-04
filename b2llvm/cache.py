"""Module providing a basic cache class

Besides the constructor, this class provides three operations: has,
get and set. It is just a wrapper around dict operations.
"""''

class Cache(object):
    '''
    This class encapsulates a map with three operations: has,
    get and set. It is just a wrapper around dict operations.
    '''
    def __init__(self):
        """Creates a new empty cache."""
        self._store = dict()

    def has(self, key) :
        """Tests if key is in the cache."""
        return key in self._store.keys()

    def get(self, key) :
        """Gets value associated to key in the cache."""
        return self._store[key]

    def set(self, key, value) :
        """Sets a key-value pair in the cache."""
        self._store[key] = value
