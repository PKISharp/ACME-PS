# Ensure IIS Static Files are served

To serve static files put a web.config in your .well-known directory (or acme-challenge directory) with the following contents:

```XML
<?xml version = "1.0" encoding="UTF-8"?>
 <configuration>
    <system.webServer>
        <staticContent>
            <mimeMap fileExtension=".*" mimeType="text/plain" />
        </staticContent>
        <handlers>
            <clear />
            <add name="StaticFile" path="*" verb="*" type="" modules="StaticFileModule,DefaultDocumentModule,DirectoryListingModule" scriptProcessor="" resourceType="Either" requireAccess="Read" allowPathInfo="false" preCondition="" responseBufferLimit="4194304" />
        </handlers>
     </system.webServer>
 </configuration>
 ```