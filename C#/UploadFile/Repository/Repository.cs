using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using System.Web;

namespace MyRepository
{
    public class Repository
    {
        private string error { get; set; }
        private string subdomain { get; set; }
        private string username { get; set; }
        private string password { get; set; }
        private string clientId { get; set; }
        private string clientSecret { get; set; }
        private string token { get; set; }

        public Repository(string token)
        {
            username = "joliver@alliantnational.com";
            password = "S@ndyL@t1mer";
            clientId = "InlFilzcMFa6enGJwAp1k00vdHoSWxpT";
            clientSecret = "KrZjnQRaEuUUnwDD9G2uYOXYv0FOS8T5zqYsO4TTMG3V7qir";
            subdomain = "alliantnational.sf-api.com";
            this.token = token;
            if (string.IsNullOrEmpty(this.token))
            {
                throw new Exception("Token is empty");
            }
        }
        
        /// <summary>
        /// Authenticate via username/password
        /// </summary>
        /// <returns>True if the authentication was successful</returns>
        public bool Authenticate()
        {
            if (!string.IsNullOrEmpty(token))
                return true;

            bool success = false;
            string uri = "https://alliantnational.sharefile.com/oauth/token";

            Dictionary<string, string> parameters = new Dictionary<string, string>
            {
                { "grant_type", "password" },
                { "client_id", clientId },
                { "client_secret", clientSecret },
                { "username", username },
                { "password", password }
            };

            ArrayList bodyParameters = new ArrayList();
            foreach (KeyValuePair<string, string> kv in parameters)
            {
                bodyParameters.Add(string.Format("{0}={1}", HttpUtility.UrlEncode(kv.Key), HttpUtility.UrlEncode(kv.Value.ToString())));
            }
            string requestBody = string.Join("&", bodyParameters.ToArray());

            HttpWebRequest request = WebRequest.CreateHttp(uri);
            request.Method = "POST";
            request.ContentType = "application/x-www-form-urlencoded";
            using (var writer = new StreamWriter(request.GetRequestStream()))
            {
                writer.Write(requestBody);
            }

            HttpWebResponse response = (HttpWebResponse)request.GetResponse();
            JObject json = null;
            using (var reader = new StreamReader(response.GetResponseStream()))
            {
                string body = reader.ReadToEnd();
                json = JObject.Parse(body);
                if (json != null)
                    success = true;
            }
            token = json["access_token"].ToString();
            subdomain = json["subdomain"].ToString() + ".sf-api.com";
            return success;
        }

        /// <summary>
        /// Get the item id from the path
        /// </summary>
        /// <param name="path">The path of the repository folder</param>
        public string GetItemByPath(string path)
        {
            string id = string.Empty;
            string uri = string.Format("https://{0}/sf/v3/Items/ByPath?path={1}", subdomain, path);

            HttpWebRequest request = WebRequest.CreateHttp(uri);
            request.Headers.Add(string.Format("Authorization: Bearer {0}", token));

            HttpWebResponse response = (HttpWebResponse)request.GetResponse();
            using (var reader = new StreamReader(response.GetResponseStream()))
            {
                string body = reader.ReadToEnd();
                JObject root = JObject.Parse(body);

                if (response.StatusCode == HttpStatusCode.OK)
                    id = root["Id"].ToString();
                else
                    error = root["value"].ToString();
            }
            return id;
        }

        /// <summary>
        /// Gets the error from the repository.
        /// </summary>
        /// <returns>The error</returns>
        public string GetLastError()
        {
            return error;
        }

        /// <summary>
        /// Uploads a File using the Standard upload method with a multipart/form mime encoded POST.
        /// </summary>
        /// <param name="parentId">where to upload the file</param>
        /// <param name="localPath">the full path of the file to upload, like "c:\\path\\to\\file.name"</param>
        public bool UploadFile(string serverPath, string localPath)
        {
            bool success = false;
            string parentId = GetItemByPath(serverPath);
            if (string.IsNullOrEmpty(parentId))
                return success;

            string uri = string.Format("https://{0}/sf/v3/Items({1})/Upload", subdomain, parentId);

            HttpWebRequest request = WebRequest.CreateHttp(uri);
            request.Headers.Add(string.Format("Authorization: Bearer {0}", token));

            HttpWebResponse response = (HttpWebResponse)request.GetResponse();
            using (var reader = new StreamReader(response.GetResponseStream()))
            {
                string body = reader.ReadToEnd();

                JObject uploadConfig = JObject.Parse(body);
                string chunkUri = (string)uploadConfig["ChunkUri"];
                if (chunkUri != null)
                    success = UploadMultiPartFile("File1", new FileInfo(localPath), chunkUri);
            }
            return success;
        }

        /// <summary>
        /// Does a multipart form post upload of a file to a url.
        /// </summary>
        /// <param name="parameterName">multipart parameter name. File1 for a standard upload.</param>
        /// <param name="file">the FileInfo to upload</param>
        /// <param name="uploadUrl">the url of the server to upload to</param>
        private bool UploadMultiPartFile(string parameterName, FileInfo file, string uploadUrl)
        {
            string boundaryGuid = "upload-" + Guid.NewGuid().ToString("n");
            string contentType = "multipart/form-data; boundary=" + boundaryGuid;

            MemoryStream ms = new MemoryStream();
            byte[] boundaryBytes = System.Text.Encoding.UTF8.GetBytes("\r\n--" + boundaryGuid + "\r\n");

            // Write MIME header
            ms.Write(boundaryBytes, 2, boundaryBytes.Length - 2);
            string header = string.Format(@"Content-Disposition: form-data; name=""{0}""; filename=""{1}""" +
                "\r\nContent-Type: application/octet-stream\r\n\r\n", parameterName, file.Name);
            byte[] headerBytes = System.Text.Encoding.UTF8.GetBytes(header);
            ms.Write(headerBytes, 0, headerBytes.Length);

            // Load the file into the byte array
            using (FileStream source = file.OpenRead())
            {
                byte[] buffer = new byte[1024 * 1024];
                int bytesRead;

                while ((bytesRead = source.Read(buffer, 0, buffer.Length)) > 0)
                {
                    ms.Write(buffer, 0, bytesRead);
                }
            }

            // Write MIME footer
            boundaryBytes = System.Text.Encoding.UTF8.GetBytes("\r\n--" + boundaryGuid + "--\r\n");
            ms.Write(boundaryBytes, 0, boundaryBytes.Length);

            byte[] postBytes = ms.ToArray();
            ms.Close();

            HttpWebRequest request = WebRequest.CreateHttp(uploadUrl);
            request.Timeout = 1000 * 60; // 60 seconds
            request.Method = "POST";
            request.ContentType = contentType;
            request.ContentLength = postBytes.Length;
            request.Credentials = CredentialCache.DefaultCredentials;

            using (Stream postStream = request.GetRequestStream())
            {
                int chunkSize = 48 * 1024;
                int remaining = postBytes.Length;
                int offset = 0;

                do
                {
                    if (chunkSize > remaining) { chunkSize = remaining; }
                    postStream.Write(postBytes, offset, chunkSize);

                    remaining -= chunkSize;
                    offset += chunkSize;

                } while (remaining > 0);

                postStream.Close();
            }

            HttpWebResponse response = (HttpWebResponse)request.GetResponse();
            return (response.StatusCode == HttpStatusCode.OK);
        }
    }
}
