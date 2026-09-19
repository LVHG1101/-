import { ApiConfig } from '../api/ApiConfig'

export function imageResource(name: string): Resource | string {
  if (name.includes('.jpg') || name.includes('.png') || name.includes('.webp') || name.includes('.gif')) {
    return ApiConfig.BASE_URL + '/uploads/' + name
  }
  if (name === 'phone1') return $r('app.media.phone1')
  if (name === 'phone2') return $r('app.media.phone2')
  if (name === 'phone3') return $r('app.media.phone3')
  if (name === 'phone4') return $r('app.media.phone4')
  if (name === 'phone5') return $r('app.media.phone5')
  if (name === 'phone6') return $r('app.media.phone6')
  if (name === 'phone7') return $r('app.media.phone7')
  if (name === 'phone8') return $r('app.media.phone8')
  if (name === 'computer') return $r('app.media.computer')
  if (name === 'tv') return $r('app.media.tv')
  if (name === 'watch') return $r('app.media.watch')
  if (name === 'hairphone') return $r('app.media.hairphone')
  if (name === 'pad') return $r('app.media.pad')
  if (name === 'airconditaion') return $r('app.media.airconditaion')
  if (name === 'icebox') return $r('app.media.icebox')
  if (name === 'washingmachine') return $r('app.media.washingmachine')
  if (name === 'lock') return $r('app.media.lock')
  if (name === 'bag') return $r('app.media.bag')
  if (name === 'brushteeth') return $r('app.media.brushteeth')
  if (name === 'rangehood') return $r('app.media.rangehood')
  if (name === 'waitcleaning') return $r('app.media.waitcleaning')
  if (name === 'washcar') return $r('app.media.washcar')
  if (name === 'fan') return $r('app.media.fan')
  return $r('app.media.phone1')
}
