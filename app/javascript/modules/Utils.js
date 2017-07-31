/*jshint esversion: 6 */

export function getCSRFfromHead() {
  if (process.env.NODE_ENV === 'test') {
    return "csrf_token"
  } else {
    return document.querySelector("meta[name=csrf-token]").content
  }
}
