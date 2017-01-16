import { createStore, applyMiddleware, combineReducers, compose } from 'redux';
import thunk from 'redux-thunk';
import rootReducer from '../reducers/rootReducer.js';
import DevTools from '../components/devTools.jsx';

const enhancer = compose(
  applyMiddleware(thunk),
  DevTools.instrument()
);

export default function configureStore(initialState) {
  const store = createStore(rootReducer, initialState, enhancer);

  if (module.hot) {
    module.hot.accept('../reducers', () =>
      store.replaceReducer(require('../reducers'))
    );
  }

  return store;
}
