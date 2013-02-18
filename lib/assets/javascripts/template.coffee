#template override for underscore to use {{}} instead of <%%>
_.templateSettings = interpolate : /\{\{(.+?)\}\}/g