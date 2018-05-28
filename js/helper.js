export function convert2Ascii(hexCode) {
  let hex = hexCode.toString();//force conversion
  let str = '';
  for (let i = 0; (i < hex.length && hex.substr(i, 2) !== '00'); i += 2) {
      str += String.fromCharCode(parseInt(hex.substr(i, 2), 16));
  }
  return str.replace(/\0/g, '')
}
