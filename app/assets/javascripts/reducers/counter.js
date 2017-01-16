import { INCREMENT_COUNTER, DECREMENT_COUNTER, SET_COUNTER } from '../actions/counter.js';

export default function counter(state = 0, action) {
  console.log(action);

  switch (action.type) {
  case INCREMENT_COUNTER:
    return state + 1;
  case DECREMENT_COUNTER:
    return state - 1;
  case SET_COUNTER:
    return action.counter;
  default:
    return state;
  }
}
