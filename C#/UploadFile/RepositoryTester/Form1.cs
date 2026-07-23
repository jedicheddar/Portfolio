using System;
using System.Drawing;
using System.Windows.Forms;
using MyRepository;

namespace Tester
{
    public partial class Form1 : Form
    {
        private readonly string username = "joliver@alliantnational.com";
        private readonly string password = "S@ndyL@t1mer";
        private readonly string clientId = "InlFilzcMFa6enGJwAp1k00vdHoSWxpT";
        private readonly string clientSecret = "KrZjnQRaEuUUnwDD9G2uYOXYv0FOS8T5zqYsO4TTMG3V7qir";

        public Form1()
        {
            InitializeComponent();
            tPath.Text = "/dev/Agent/097318";
        }

        private void bUpload_Click(object sender, EventArgs e)
        {
            Repository repo = new Repository(tToken.Text);
            Cursor.Current = Cursors.WaitCursor;
            if (!repo.Authenticate())
                return;

            if (tPath.Text.Equals("") || tFile.Text.Equals(""))
            {
                Cursor.Current = Cursors.Default;
                if (tPath.Text.Equals(""))
                    tPath.BackColor = Color.LightPink;
                if (tFile.Text.Equals(""))
                    tFile.BackColor = Color.LightPink;
                return;
            }

            if (!repo.UploadFile(tPath.Text, tFile.Text))
                MessageBox.Show(repo.GetLastError());
            else
                MessageBox.Show("Upload Successful");
            Cursor.Current = Cursors.Default;
        }

        private void tFile_MouseClick(object sender, EventArgs e)
        {
            OpenFileDialog openFile = new OpenFileDialog();
            openFile.Title = "Upload File";
            if (openFile.ShowDialog() == DialogResult.OK)
            {
                tFile.BackColor = Color.White;
                tFile.Text = openFile.FileName;
            }
        }

        private void tPath_TextChanged(object sender, EventArgs e)
        {
            tPath.BackColor = Color.White;
        }

        private void tFile_TextChanged(object sender, EventArgs e)
        {

        }
    }
}
