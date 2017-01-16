import { combineReducers } from 'redux';
import counter from './counter.js';

const rootReducer = combineReducers({
  counter
});

export default rootReducer;
