" Vim plugin of checking words spell on the code.
" Version 1.0.0
" Author kamykn
" License VIM LICENSE

scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

function! spelunker#white_list#white_list_php#get_white_list()
	" php -r 'foreach (get_defined_functions()["internal"] as $fn ) {echo $fn . "\n";}'
	let l:wl = ['acos', 'acosh', 'addcslashes', 'addslashes', 'uassoc', 'ukey', 'multisort', 'udiff', 'uintersect', 'unshift', 'arsort', 'asin', 'asinh', 'asort', 'ast', 'atan', 'atanh', 'basename', 'bcadd', 'bccomp', 'bcdiv', 'bcmod', 'bcmul', 'bcpow', 'bcpowmod', 'bcscale', 'bcsqrt', 'bcsub', 'textdomain', 'codeset', 'bindec', 'bindtextdomain', 'boolval', 'bzclose', 'bzcompress', 'bzdecompress', 'bzerrno', 'bzerror', 'bzerrstr', 'bzflush', 'bzopen', 'bzread', 'bzwrite', 'jd', 'ceil', 'chdir', 'checkdate', 'checkdnsrr', 'chgrp', 'chr', 'clearstatcache', 'cli', 'closedir', 'closelog', 'cyr', 'uudecode', 'uuencode', 'crc', 'ctype', 'alnum', 'cntrl', 'punct', 'xdigit', 'errno', 'getinfo', 'getcontent', 'setopt','strerror', 'unescape', 'isodate', 'timestamp', 'datefmt', 'datetype', 'timetype', 'localtime', 'dba', 'firstkey', 'nextkey', 'popen', 'dcgettext', 'dcngettext', 'zval', 'decbin', 'dechex', 'dgettext', 'dir', 'dirname', 'diskfreespace', 'dl', 'dngettext', 'dns', 'mx', 'simplexml', 'doubleval', 'easter', 'escapeshellarg', 'escapeshellcmd', 'exif', 'imagetype', 'tagname', 'expm', 'ezmlm', 'fclose', 'feof', 'fflush', 'fgetc', 'fgetcsv', 'fgets', 'fgetss', 'fileatime','filectime', 'filegroup', 'fileinode', 'filemtime', 'fileowner', 'fileperms', 'filesize', 'filetype', 'finfo', 'floatval', 'fmod', 'fnmatch', 'fopen', 'fpassthru', 'fprintf', 'fputcsv', 'fputs', 'fread', 'frenchtojd', 'fscanf', 'fseek', 'fsockopen', 'fstat', 'ftell', 'ftok', 'alloc', 'cdup', 'fget', 'fput', 'mdtm', 'mlsd', 'nb', 'nlist', 'pasv', 'rawlist', 'systype', 'ftruncate', 'arg', 'args', 'num', 'fwrite', 'gc', 'mem', 'gd', 'cfg', 'funcs', 'gpc', 'getcwd', 'getdate', 'getenv', 'gethostbyaddr', 'gethostbyname', 'gethostbynamel', 'gethostname', 'getimagesize', 'getimagesizefromstring', 'getlastmod', 'getmxrr', 'getmygid', 'getmyinode', 'getmypid', 'getmyuid', 'getopt', 'getprotobyname', 'getprotobynumber', 'getrandmax', 'getrusage', 'getservbyname', 'getservbyport', 'gettext', 'gettimeofday', 'gettype', 'gmdate', 'gmmktime', 'gmp', 'clrbit', 'cmp', 'divexact', 'gcd', 'gcdext', 'hamdist', 'intval', 'jacobi', 'legendre', 'mul', 'nextprime', 'popcount', 'powm', 'rootrem', 'setbit', 'sqrtrem', 'strval', 'testbit', 'gmstrftime', 'stripos', 'stristr', 'strlen', 'strpos', 'strripos', 'strrpos', 'strstr', 'substr', 'gregoriantojd', 'gzclose', 'gzcompress', 'gzdecode', 'gzdeflate', 'gzencode', 'gzeof', 'gzfile', 'gzgetc', 'gzgets', 'gzgetss', 'gzinflate', 'gzopen', 'gzpassthru', 'gzputs', 'gzread', 'gzrewind', 'gzseek', 'gztell', 'gzuncompress', 'gzwrite', 'algos', 'hkdf', 'hmac', 'pbkdf', 'hebrev', 'hebrevc', 'hexdec', 'htmlentities', 'htmlspecialchars', 'hypot', 'iconv', 'idate', 'idn', 'wbmp', 'imageaffine', 'imageaffinematrixconcat', 'imageaffinematrixget', 'imagealphablending', 'imageantialias', 'imagearc', 'imagebmp', 'imagechar', 'imagecharup', 'imagecolorallocate', 'imagecolorallocatealpha', 'imagecolorat', 'imagecolorclosest', 'imagecolorclosestalpha', 'imagecolorclosesthwb', 'imagecolordeallocate', 'imagecolorexact', 'imagecolorexactalpha', 'imagecolormatch', 'imagecolorresolve', 'imagecolorresolvealpha', 'imagecolorset', 'imagecolorsforindex', 'imagecolorstotal', 'imagecolortransparent', 'imageconvolution', 'imagecopy', 'imagecopymerge', 'imagecopymergegray', 'imagecopyresampled', 'imagecopyresized', 'imagecreate', 'imagecreatefrombmp', 'imagecreatefromgd', 'imagecreatefromgif', 'imagecreatefromjpeg', 'imagecreatefrompng', 'imagecreatefromstring', 'imagecreatefromwbmp', 'imagecreatefromwebp', 'imagecreatefromxbm', 'imagecreatetruecolor', 'imagecrop', 'imagecropauto', 'imagedashedline', 'imagedestroy', 'imageellipse', 'imagefill', 'imagefilledarc', 'imagefilledellipse', 'imagefilledpolygon', 'imagefilledrectangle', 'imagefilltoborder', 'imagefilter', 'imageflip', 'imagefontheight', 'imagefontwidth', 'imageftbbox', 'imagefttext', 'imagegammacorrect', 'imagegd', 'imagegetclip', 'imagegif', 'imageinterlace', 'imageistruecolor', 'imagejpeg', 'imagelayereffect', 'imageline', 'imageloadfont', 'imageopenpolygon', 'imagepalettecopy', 'imagepalettetotruecolor', 'imagepng', 'imagepolygon', 'imagerectangle', 'imageresolution', 'imagerotate', 'imagesavealpha', 'imagescale', 'imagesetbrush', 'imagesetclip','imagesetinterpolation', 'imagesetpixel', 'imagesetstyle', 'imagesetthickness', 'imagesettile', 'imagestring', 'imagestringup', 'imagesx', 'imagesy', 'imagetruecolortopalette', 'imagettfbbox', 'imagettftext', 'imagetypes', 'imagewbmp', 'imagewebp', 'imagexbm', 'inet', 'ntop', 'pton', 'len', 'ini', 'intdiv', 'intl', 'intlcal', 'intlgregcal', 'gregorian', 'intltz', 'dst', 'gmt', 'tz', 'ip', 'iptcembed', 'iptcparse', 'iterable', 'jddayofweek', 'jdmonthname', 'jdtofrench', 'jdtogregorian', 'jdtojewish', 'jdtojulian', 'jdtounix', 'jewishtojd', 'jpeg', 'msg', 'juliantojd', 'krsort', 'ksort', 'lcfirst', 'lcg', 'lchgrp', 'lchown', 'ldap', 'dn', 'ufn', 'exop', 'passwd', 'whoami', 'sasl', 'levenshtein', 'libxml', 'linkinfo', 'localeconv', 'lstat', 'ltrim', 'mb', 'mimeheader', 'numericentity', 'ereg', 'getpos', 'getregs', 'regs', 'setpos', 'eregi', 'ord', 'strcut', 'strimwidth', 'strrchr', 'strrichr', 'strtolower', 'strtoupper', 'strwidth', 'mbereg', 'mberegi', 'mbregex', 'mbsplit', 'md', 'metaphone', 'mhash', 'keygen', 'microtime', 'mktime', 'msgfmt', 'srand', 'mysqli', 'autocommit', 'charset', 'proto', 'savepoint', 'sqlstate', 'stmt', 'natcasesort', 'natsort', 'ngettext', 'nl', 'br', 'langinfo', 'numfmt', 'gzhandler', 'octdec', 'odbc', 'binmode', 'columnprivileges', 'errormsg', 'foreignkeys', 'gettypeinfo', 'longreadlen', 'pconnect', 'primarykeys', 'procedurecolumns', 'setoption', 'specialcolumns', 'tableprivileges', 'opcache', 'opendir', 'openlog', 'openssl', 'csr', 'dh', 'privatekey', 'publickey', 'pkcs', 'pkey', 'spki', 'checkpurpose', 'passthru', 'pathinfo', 'pclose', 'pcntl', 'getpriority', 'setpriority', 'sigprocmask', 'waitpid', 'wexitstatus', 'wifcontinued', 'wifexited', 'wifsignaled', 'wifstopped', 'wstopsig', 'wtermsig', 'pdo', 'pfsockopen', 'clientencoding', 'cmdtuples', 'dbname', 'errormessage', 'bytea', 'prtlen', 'oid', 'fieldisnull', 'fieldname', 'fieldnum', 'fieldprtlen', 'fieldsize', 'fieldtype', 'freeresult', 'pid', 'getlastoid', 'loclose', 'locreate', 'loexport', 'loimport', 'loopen', 'loread', 'loreadall', 'lounlink', 'lowrite', 'numfields', 'numrows', 'params', 'setclientencoding', 'tty', 'untrace', 'sapi', 'whitespace', 'uname', 'phpcredits', 'phpinfo', 'phpversion', 'png', 'posix', 'ctermid', 'getegid', 'geteuid', 'getgid', 'getgrgid', 'getgrnam', 'getgroups', 'getlogin', 'getpgid', 'getpgrp', 'getpid', 'getppid', 'getpwnam', 'getpwuid', 'getrlimit', 'getsid', 'getuid', 'initgroups', 'isatty', 'mkfifo', 'mknod', 'setegid', 'seteuid', 'setgid', 'setpgid', 'setrlimit', 'setsid', 'setuid', 'ttyname', 'preg', 'printf', 'pspell', 'repl', 'runtogether', 'putenv', 'quotemeta', 'rawurldecode', 'rawurlencode', 'readdir', 'readfile', 'readgzfile', 'readline', 'readlink', 'realpath', 'resourcebundle', 'rewinddir', 'rsort', 'rtrim', 'scandir', 'sem', 'setcookie', 'setlocale', 'setrawcookie', 'settype', 'sha', 'shm', 'shmop', 'sinh', 'addrinfo', 'cmsg', 'getpeername', 'getsockname', 'recv', 'recvfrom', 'recvmsg', 'sendmsg', 'sendto', 'nonblock', 'aead', 'aes', 'gcm', 'chacha', 'ietf', 'xchacha', 'keypair', 'secretkey', 'generichash', 'kdf', 'kx', 'pwhash', 'scryptsalsa', 'scalarmult', 'secretbox', 'secretstream', 'rekey', 'shorthash', 'sk', 'memcmp', 'memzero', 'unpad', 'soundex', 'spl', 'unregister', 'sprintf', 'sscanf', 'getcsv', 'ireplace', 'strcasecmp', 'strchr', 'strcmp', 'strcoll', 'strcspn', 'strftime', 'stripcslashes', 'stripslashes', 'strnatcasecmp', 'strnatcmp', 'strncasecmp', 'strncmp', 'strpbrk', 'strptime', 'strrev', 'strspn', 'strtok', 'strtotime', 'strtr', 'sys', 'getloadavg', 'syslog', 'tanh', 'tempnam', 'nanosleep', 'tmpfile', 'transliterator', 'uasort', 'ucfirst', 'ucwords', 'uksort', 'umask', 'uniqid', 'unixtojd', 'unserialize', 'urldecode', 'urlencode', 'usleep', 'usort', 'vfprintf', 'vprintf', 'vsprintf', 'wddx', 'deserialize', 'wordwrap', 'xml', 'ns', 'decl', 'xmlrpc', 'xmlwriter', 'cdata', 'dtd', 'attlist', 'uri', 'zend', 'compressedsize', 'compressionmethod', 'zlib']

	" php -r 'foreach (get_defined_constants() as $def => $_) { echo $def . "\n"; }' | sort -u
	let l:wl += ['abday', 'abmon', 'af', 'inet', 'ai', 'addrconfig', 'canonname', 'numerichost', 'numericserv', 'dow', 'dayno', 'easter', 'gregorian', 'julian', 'jewish', 'alafim', 'geresh', 'gereshayim', 'num', 'cals', 'codeset', 'fullpage', 'sapi','crncystr', 'des', 'md', 'sha', 'curlauth', 'anysafe', 'ie', 'gssnegotiate', 'ntlm', 'wb', 'curle', 'couldnt', 'filesize', 'retr', 'stor', 'pasv', 'ldap', 'malformat', 'ok', 'timedout', 'timeouted', 'recv', 'cacert', 'badfile', 'certproblem', 'notfound', 'setfailed', 'pinnedpubkeynotmatch', 'curlftpauth', 'curlftpmethod', 'multicwd', 'nocwd', 'singlecwd', 'curlftpssl', 'ccc', 'curlftp', 'dir', 'curlgssapi', 'curlheader', 'curlinfo', 'appconnect', 'certinfo', 'cookielist', 'filetime', 'httpauth', 'connectcode', 'lastone', 'ip', 'namelookup', 'os', 'errno', 'pretransfer', 'proxyauth', 'rtsp', 'cseq', 'verifyresult', 'starttransfer', 'curlmopt', 'maxconnects', 'pipelining', 'pushfunction', 'curlmsg', 'curlm', 'curlopt', 'accepttimeout', 'autoreferer', 'binarytransfer', 'buffersize', 'cainfo', 'capath', 'connecttimeout', 'cookiefile', 'cookiejar', 'cookiesession', 'crlf', 'crlfile', 'customrequest', 'dirlistonly', 'dns', 'egdsocket', 'failonerror', 'fnmatch', 'followlocation', 'ftpappend', 'ftplistonly', 'ftpport', 'ftpsslauth', 'dirs', 'filemethod', 'eprt', 'epsv', 'pret', 'gssapi', 'headerfunction', 'headeropt', 'httpget', 'httpheader', 'httpproxytunnel', 'infile', 'infilesize', 'ipresolve', 'issuercert', 'keypasswd', 'krb', 'krblevel', 'localport', 'localportrange', 'maxfilesize', 'maxredirs', 'netrc', 'noprogress', 'noproxy', 'nosignal', 'pinnedpublickey', 'pipewait', 'postfields', 'postquote', 'postredir', 'prequote', 'progressfunction', 'proxyheader', 'proxypassword', 'proxyport', 'proxytype', 'proxyusername', 'proxyuserpwd', 'readdata', 'readfunction', 'redir', 'returntransfer', 'uri', 'sasl', 'ir', 'nec', 'knownhosts', 'keyfile', 'sslcert', 'sslcertpasswd', 'sslcerttype', 'sslengine', 'sslkey', 'sslkeypasswd', 'sslkeytype', 'sslversion', 'alpn', 'npn', 'falsestart', 'sessionid', 'verifyhost', 'verifypeer', 'verifystatus', 'stderr', 'fastopen','keepalive', 'keepidle', 'keepintvl', 'nodelay', 'telnetoptions', 'tftp', 'blksize', 'timecondition', 'timevalue', 'tlsauth', 'transfertext', 'useragent', 'userpwd', 'wildcardmatch', 'writefunction', 'writeheader', 'xoauth', 'curlpause', 'curlpipe', 'curlproto', 'imaps', 'ldaps', 'rtmp', 'rtmpe', 'rtmps', 'rtmpt', 'rtmpte', 'rtmpts', 'smb', 'smbs', 'smtp', 'smtps', 'curlproxy', 'hostname', 'curlshopt', 'unshare', 'curlssh', 'publickey', 'curlsslopt', 'curlusessl', 'curlversion', 'fnmatchfunc', 'nomatch', 'readfunc', 'rtspreq', 'teardown', 'sslv', 'tlsv', 'timecond', 'ifmodsince', 'ifunmodsince', 'lastmod', 'srp', 'ipv', 'kerberos', 'libz', 'writefunc', 'iso', 'rfc', 'rss', 'args', 'aaaa', 'caa','cname', 'hinfo', 'mx', 'naptr', 'ns', 'soa', 'srv', 'txt', 'domstring', 'inuse', 'fmt', 'ent', 'compat', 'noquotes', 'xhtml', 'xml', 'exif', 'mbstring', 'extr', 'fileinfo', 'atime', 'unicode', 'fnm', 'casefold', 'noescape', 'autoresume', 'autoseek', 'moredata', 'usepasvaddress', 'gd', 'nocheck', 'nosort', 'onlydir', 'gmp', 'lsw', 'msw', 'minusinf', 'plusinf', 'maxbytes', 'maxchars', 'hmac', 'specialchars', 'iconv', 'idna', 'bidi', 'contextj', 'punycode', 'nontransitional', 'imagetype', 'bmp', 'gif', 'ico', 'iff', 'jb', 'jp', 'jpc', 'jpeg', 'jpx', 'png', 'psd', 'swc', 'swf', 'wbmp', 'webp', 'xbm', 'img', 'nofill', 'bessel', 'bicubic', 'blackman', 'bspline', 'catmullrom', 'styledbrushed', 'alphablend', 'edgedetect', 'gaussian', 'grayscale', 'pixelate', 'hanning', 'hermite', 'mitchell', 'sinc', 'xpm', 'ini', 'perdir', 'intl', 'icu', 'uts', 'len', 'ipproto', 'recvtclass', 'tclass', 'bigint', 'apos', 'unescaped', 'lc', 'ctype', 'dontusecopy', 'managedsait', 'pagedresults', 'passwordpolicyrequest', 'passwordpolicyresponse', 'authz', 'sortrequest', 'sortresponse', 'subentries', 'valuesreturnfilter', 'vlvrequest', 'vlvresponse', 'dn', 'deref', 'exop', 'passwd', 'attrib', 'modtype', 'sizelimit', 'timelimit', 'authcid', 'authzid', 'mech', 'nocanon', 'cacertdir', 'cacertfile', 'certfile', 'crlcheck', 'crl', 'dhfile', 'libexslt', 'libxml', 'biglines', 'dtdattr', 'dtdload', 'dtdvalid', 'nodefdtd', 'noimplied', 'noblanks', 'nocdata', 'noemptytag', 'noent', 'noerror', 'nonet', 'nowarning', 'noxmldecl', 'nsclean', 'parsehuge', 'xinclude', 'libxslt', 'nb', 'un', 'authpriv', 'crit', 'emerg', 'kern', 'lpr', 'ndelay', 'nowait', 'odelay', 'perror', 'pid', 'syslog', 'mb', 'mcast', 'mhash', 'adler', 'crc', 'fnv', 'gost', 'haval', 'joaat', 'ripemd', 'snefru', 'mon', 'msg', 'ctrunc', 'dontroute', 'dontwait', 'eagain', 'enomsg', 'eof', 'eor', 'ipc', 'oob', 'trunc', 'waitall', 'mysqli', 'dont', 'pri', 'ps', 'params', 'charset', 'stmt', 'timestamp', 'datetime', 'longlong', 'newdate', 'newdecimal', 'zerofill', 'sqrtpi', 'euler', 'ln', 'lnpi', 'noexpr', 'nostr', 'odbc', 'binmode', 'passthru', 'openssl', 'algo', 'dss', 'rmd', 'aes', 'cbc', 'keytype', 'dh', 'dsa', 'ec', 'rsa', 'pkcs', 'oaep', 'tlsext', 'bcrypt', 'pathinfo', 'basename', 'dirname', 'pcntl', 'eacces', 'echild', 'efault', 'eintr', 'einval', 'eio', 'eisdir', 'eloop', 'emfile','enametoolong', 'enfile', 'enoent', 'enoexec', 'enomem', 'enotdir', 'eperm', 'esrch', 'etxtbsy', 'pcre', 'pgsql', 'setenv', 'conv', 'diag', 'sqlstate', 'dml', 'libpq', 'inerror', 'bindir', 'datadir', 'eol', 'fd', 'setsize', 'libdir', 'localstatedir', 'mandir', 'maxpathlen', 'stdflags', 'shlib', 'sysconfdir', 'zts', 'noattr', 'nocerts', 'nochain', 'nointern', 'nosigs', 'noverify', 'paeth', 'posix', 'rlimit', 'cpu', 'fsize', 'memlock', 'nofile', 'nproc', 'ifblk', 'ifchr', 'ififo', 'ifreg', 'ifsock', 'preg', 'jit', 'stacklimit', 'delim', 'prio', 'pgrp', 'psfs', 'pspell', 'radixchar', 'readline', 'scandir', 'scm', 'sigabrt', 'sigalrm', 'sigbaby', 'sigbus', 'sigchld', 'sigcont', 'sigfpe', 'sighup', 'sigill', 'sigint', 'sigio', 'sigiot', 'sigkill', 'sigpipe', 'sigprof', 'sigquit', 'sigsegv', 'sigstop', 'sigsys', 'sigterm', 'sigtrap', 'sigtstp', 'sigttin', 'sigttou', 'sigurg', 'sigusr', 'sigvtalrm', 'sigwinch', 'sigxcpu', 'sigxfsz','sig', 'dfl', 'ign', 'setmask', 'unlimatereceiver', 'rpc', 'xsi', 'eaddrinuse', 'eaddrnotavail', 'eafnosupport', 'ealready', 'ebadf', 'ebadmsg', 'ebusy', 'econnaborted', 'econnrefused', 'econnreset', 'edestaddrreq', 'edquot', 'eexist', 'ehostdown', 'ehostunreach', 'eidrm', 'einprogress', 'eisconn', 'emlink', 'emsgsize', 'emultihop', 'enetdown', 'enetreset', 'enetunreach', 'enobufs', 'enodata', 'enodev', 'enolck', 'enolink', 'enoprotoopt', 'enospc', 'enosr', 'enostr', 'enosys', 'enotblk', 'enotconn', 'enotempty', 'enotsock', 'enotty', 'enxio', 'eopnotsupp', 'epfnosupport', 'epipe', 'eproto', 'eprotonosupport', 'eprototype', 'eremote', 'erofs', 'eshutdown', 'esocktnosupport', 'espipe', 'etime', 'etimedout', 'etoomanyrefs', 'eusers', 'ewouldblock', 'exdev', 'dgram', 'rdm', 'seqpacket', 'urlsafe', 'aead', 'aes', 'gcm', 'abytes', 'keybytes', 'npubbytes', 'nsecbytes', 'chacha', 'ietf', 'xchacha', 'keypairbytes', 'macbytes', 'noncebytes', 'publickeybytes', 'sealbytes', 'secretkeybytes', 'seedbytes', 'generichash', 'kdf', 'contextbytes', 'kx', 'sessionkeybytes', 'pwhash', 'alg', 'memlimit', 'opslimit', 'saltbytes', 'scryptsalsa', 'strprefix', 'scalarmult', 'scalarbytes', 'secretbox', 'secretstream', 'headerbytes', 'messagebytes', 'rekey', 'shorthash', 'somaxconn', 'oobinline', 'rcvbuf', 'rcvlowat', 'rcvtimeo', 'reuseaddr', 'reuseport', 'sndbuf', 'sndlowat', 'sndtimeo', 'sqlite', 'readwrite', 'sql', 'rowid', 'rowver', 'keyset', 'longvarbinary', 'longvarchar', 'currow', 'smallint', 'tinyint', 'varbinary', 'wlongvarchar', 'wvarchar', 'stdin', 'stdout', 'icmp', 'rdwr', 'wr', 'sunfuncs', 'ret', 'thousep', 'concat', 'encapsed', 'dec', 'dnumber', 'whitespace', 'heredoc', 'ampm', 'lnumber', 'mul', 'paamayim', 'nekudotayim', 'sl', 'sr', 'varname', 'uloc', 'brk', 'paren', 'redfinition', 'ce', 'uca', 'outofbounds', 'transliterator', 'rbt', 'pragma', 'seperators', 'permill', 'lt', 'safeclone', 'stringprep', 'unterminated', 'wcontinued', 'wnohang', 'wsdl', 'wuntraced', 'smime', 'cdata', 'decl', 'idref', 'idrefs', 'nmtoken', 'nmtokens', 'dtd', 'tagstart', 'xsd', 'timeinstant', 'xsd', 'anytype', 'anyuri', 'anyxml', 'gday', 'gmonth', 'gmonthday', 'gyear', 'gyearmonth', 'hexbinary', 'ncname', 'negativeinteger', 'nonnegativeinteger', 'nonpositiveinteger', 'normalizedstring', 'positiveinteger', 'qname', 'unsignedbyte', 'unsignedint', 'unsignedlong', 'unsignedshort', 'xsl', 'secpref', 'yesexpr', 'yesstr', 'zend', 'zlib', 'buf', 'huffman', 'mem', 'rle', 'vernum', 'ast', 'arg', 'encaps', 'expr', 'fq', 'variadic', 'iterable']

	let l:wl += ['bcmath', 'bz', 'guid', 'typelib', 'typeinfo', 'eqv', 'idiv', 'dbase', 'numrecords', 'spliti', 'regcase', 'fbsql', 'clob', 'autostart', 'dbs', 'characterset', 'tablename', 'fdf', 'ap', 'imagecreatefromxpm', 'imagegrabscreen', 'imagegrabwindow', 'imagepsbbox', 'imagepscopyfont', 'imagepsencodefont', 'imagepsextendfont', 'imagepsfreefont', 'imagepsloadfont', 'imagepsslantfont', 'imagepstext', 'bodystruct', 'clearflag', 'createmailbox', 'deletemailbox', 'fetchbody', 'fetchheader', 'fetchstructure', 'fetchtext', 'quotaroot','getacl', 'getmailboxes', 'getsubscribed', 'headerinfo', 'listmailbox', 'listsubscribed', 'lsub', 'mailboxmsginfo', 'msgno', 'qprint', 'renamemailbox', 'adrlist', 'savebody', 'scanmailbox', 'setacl', 'setflag', 'uid', 'interbase', 'ibase', 'fbird', 'errcode', 'errmsg', 'mcrypt', 'cfb', 'ecb', 'deinit', 'ofb', 'mdecrypt', 'ming', 'keypress', 'setcubicthreshold', 'setscale', 'setswfcompression', 'useconstants', 'useswfversion', 'swfaction', 'swfbitmap', 'swfbutton', 'swfdisplayitem', 'swffill', 'swffontchar', 'swffont', 'swfgradient', 'swfmorph', 'swfsound', 'swfsoundinstance', 'swfvideostream', 'swfprebuiltclip', 'swfmovie', 'swfshape', 'swfsprite', 'swftext', 'swftextfield', 'msql', 'createdb','dropdb', 'fieldflags', 'fieldlen', 'fieldtable', 'listdbs', 'listfields', 'listtables', 'selectdb', 'mssql', 'fe', 'rpl', 'mysqlnd', 'oci', 'ocibindbyname', 'ocicancel', 'ocicollappend', 'ocicollassignelem', 'ocicollgetelem', 'ocicollmax', 'ocicollsize', 'ocicolltrim', 'ocicolumnisnull', 'ocicolumnname', 'ocicolumnprecision', 'ocicolumnscale', 'ocicolumnsize', 'ocicolumntype', 'ocicolumntyperaw', 'ocicommit', 'ocidefinebyname', 'ocierror', 'ociexecute', 'ocifetch', 'ocifetchinto', 'ocifetchstatement', 'ocifreecollection', 'ocifreecursor', 'ocifreedesc', 'ocifreestatement', 'ocigetbufferinglob', 'ociinternaldebug', 'ociloadlob', 'ocilogoff', 'ocilogon', 'ocinewcollection', 'ocinewcursor', 'ocinewdescriptor', 'ocinlogon', 'ocinumcols', 'ociparse', 'ocipasswordchange', 'ociplogon', 'ociresult', 'ocirollback', 'ocirowcount', 'ocisavelob', 'ocisavelobfile', 'ociserverversion', 'ocisetbufferinglob', 'ocisetprefetch', 'ocistatementtype', 'ociwritelobtofile', 'birdstep', 'velocis', 'dbh', 'dbstmt', 'dblib', 'firebird', 'sxe', 'extname', 'snmp', 'getnext', 'valueretrieval', 'mib', 'snmpget', 'snmpgetnext', 'snmprealwalk', 'snmpset', 'snmpwalk', 'snmpwalkoid', 'winsnmp', 'seekable', 'libencoding', 'libversion', 'udf', 'ub', 'chroot', 'strtotitle', 'sybase', 'sysvmsg', 'sysvsem', 'sysvshm', 'ver', 'tokenizer', 'titlecase', 'subst', 'xmlreader', 'epi', 'aolserver', 'getallheaders', 'cgi', 'capi', 'smfi', 'addheader', 'addrcpt', 'chgheader', 'delrcpt', 'getsymval', 'replacebody', 'setflags', 'setreply', 'settimeout', 'nsapi']

	return l:wl
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
