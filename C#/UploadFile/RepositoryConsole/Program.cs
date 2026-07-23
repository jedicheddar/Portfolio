using System;
using System.IO;
using System.Linq;
using MyRepository;

namespace Console
{
    class Program
    {
        static void Main(string[] args)
        {
            DateTime start = DateTime.Now;
            if (args.Count() == 0)
                return;

            //first argument is the token
            string token = args[0];

            //next argument is the server path
            string serverPath = args[1];

            //next argument is the local file
            string localFile = args[2];
            
            try
            {
                Repository repo = new Repository(token);
                if (repo == null)
                    return;

                repo.UploadFile(serverPath, localFile);
            }
            catch (Exception e)
            {
                string logFile = Path.GetTempPath() + "RepositoryConsole.log";
                using (StreamWriter sw = new StreamWriter(logFile))
                {
                    sw.WriteLine("Exception found: " + e.Message);
                    sw.WriteLine("Stack Trace: " + e.StackTrace);
                    sw.Close();
                }
            }

            DateTime end = DateTime.Now;
            System.Diagnostics.Debug.WriteLine(end - start);
        }
    }
}
