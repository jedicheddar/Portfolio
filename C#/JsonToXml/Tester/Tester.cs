using System;
using System.Windows.Forms;

namespace Tester
{
    public partial class Tester : Form
    {
        public Tester()
        {
            InitializeComponent();
        }

        private void bConvert_Click(object sender, EventArgs e)
        {
            tXML.Text = JsonToXml.JsonToXml.ConvertJson(tJSON.Text, "Root");
        }
    }
}
