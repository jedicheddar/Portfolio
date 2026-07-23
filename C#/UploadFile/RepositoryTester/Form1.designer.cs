namespace Tester
{
    partial class Form1
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.tPath = new System.Windows.Forms.TextBox();
            this.label1 = new System.Windows.Forms.Label();
            this.bUpload = new System.Windows.Forms.Button();
            this.tFile = new System.Windows.Forms.TextBox();
            this.label2 = new System.Windows.Forms.Label();
            this.fileDialog = new System.Windows.Forms.OpenFileDialog();
            this.label3 = new System.Windows.Forms.Label();
            this.tToken = new System.Windows.Forms.TextBox();
            this.SuspendLayout();
            // 
            // tPath
            // 
            this.tPath.Location = new System.Drawing.Point(59, 12);
            this.tPath.Name = "tPath";
            this.tPath.Size = new System.Drawing.Size(145, 22);
            this.tPath.TabIndex = 1;
            this.tPath.TextChanged += new System.EventHandler(this.tPath_TextChanged);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(12, 15);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(41, 17);
            this.label1.TabIndex = 2;
            this.label1.Text = "Path:";
            // 
            // bUpload
            // 
            this.bUpload.Location = new System.Drawing.Point(213, 70);
            this.bUpload.Name = "bUpload";
            this.bUpload.Size = new System.Drawing.Size(73, 27);
            this.bUpload.TabIndex = 3;
            this.bUpload.Text = "Upload";
            this.bUpload.UseVisualStyleBackColor = true;
            this.bUpload.Click += new System.EventHandler(this.bUpload_Click);
            // 
            // tFile
            // 
            this.tFile.Location = new System.Drawing.Point(59, 42);
            this.tFile.Name = "tFile";
            this.tFile.Size = new System.Drawing.Size(424, 22);
            this.tFile.TabIndex = 4;
            this.tFile.MouseClick += new System.Windows.Forms.MouseEventHandler(this.tFile_MouseClick);
            this.tFile.TextChanged += new System.EventHandler(this.tFile_TextChanged);
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(12, 45);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(34, 17);
            this.label2.TabIndex = 5;
            this.label2.Text = "File:";
            // 
            // fileDialog
            // 
            this.fileDialog.FileName = "fileDialog";
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(210, 15);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(52, 17);
            this.label3.TabIndex = 6;
            this.label3.Text = "Token:";
            // 
            // tToken
            // 
            this.tToken.Location = new System.Drawing.Point(268, 14);
            this.tToken.Name = "tToken";
            this.tToken.Size = new System.Drawing.Size(215, 22);
            this.tToken.TabIndex = 7;
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 16F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(495, 109);
            this.Controls.Add(this.tToken);
            this.Controls.Add(this.label3);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.tFile);
            this.Controls.Add(this.bUpload);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.tPath);
            this.Name = "Form1";
            this.Text = "Form1";
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.TextBox tPath;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Button bUpload;
        private System.Windows.Forms.TextBox tFile;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.OpenFileDialog fileDialog;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.TextBox tToken;
    }
}

