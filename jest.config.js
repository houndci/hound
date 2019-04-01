module.exports = {
  moduleNameMapper: {
    '^.+\\.(css|scss)$': 'identity-obj-proxy'
  },
  roots: ['app/javascript/__tests__/'],
  setupFiles: ['<rootDir>/app/javascript/__tests__/setup.js'],
  snapshotSerializers: ['<rootDir>/node_modules/enzyme-to-json/serializer'],
  testPathIgnorePatterns: ['app/javascript/__tests__/setup.js'],
  unmockedModulePathPatterns: ['react', 'enzyme'],
};
