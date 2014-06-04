using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.IO;
using System;
using System.IO.Ports;
using System.Threading;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Windows.Forms.DataVisualization.Charting;
using System.IO;

namespace eeporm_tool
{
    public partial class Form1 : Form
    {
        SerialPort port = null;

        public Form1()
        {
            InitializeComponent();
            comboBox2.SelectedIndex = 4;

            for (int i = 0; i <= 20; i++)
            {
                port = new SerialPort("COM" + Convert.ToInt32(i), 62500, Parity.None, 8, StopBits.One);
                try
                {
                    port.Open();
                    comboBox1.Items.Add("COM" + Convert.ToInt32(i));
                    port.Close();
                }
                catch (Exception){

                }
                port = null;
            }

            if (comboBox1.Items.Count > 0)
            {
                comboBox1.SelectedIndex = 0;
            }
            else
                Application.Exit();

            if (comboBox3.Items.Count > 0)
            {
                comboBox3.SelectedIndex = 0;
            }
        }

        private void anzeigen()
        {
            label1.Show();
            label2.Show();
            label3.Show();
            label4.Show();
            label5.Show();
            label6.Show();
            label9.Show();
            label10.Show();
            button2.Show();
        }

        private void verbergen()
        {
            label1.Hide();
            label2.Hide();
            label3.Hide();
            label4.Hide();
            label5.Hide();
            label6.Hide();
            label9.Hide();
            label10.Hide();
            button2.Hide();
        }

        private void anzeigen2()
        {
            button3.Show();
            button4.Show();
            button5.Show();
            chart1.Show();
            comboBox2.Show();
            listBox1.Show();
            listBox2.Show();
            listBox1.Items.Clear();
            listBox2.Items.Clear();
            checkedListBox1.Hide();
            chart1.Series.Clear();
        }

        private void verbergen2()
        {
            button3.Hide();
            button4.Hide();
            button5.Hide();
            chart1.Hide();
            comboBox2.Hide();
            listBox1.Hide();
            listBox2.Hide();
            checkedListBox1.Hide();
        }

        private void Fehler(bool zustand)
        {
            if (zustand)
            {
                label7.Show();
                verbergen();
            }
            else
            {
                label7.Hide();
                anzeigen();
            }
        }

        private void button1_Click(object sender, EventArgs e)
        {
            if (button1.Text == "Verbinden")
            {
                try
                {
                    port = new SerialPort(comboBox1.Text, 62500, Parity.None, 8, StopBits.One);
                    port.ReadBufferSize = 100000;
                    port.Open();
                   // port.ReadBufferSize = 100;
                    anzeigen();
                    anzeigen2();
                    Fehler(false);
                    label4.Text = "0 Byte";
                    label5.Text = "0 Byte";
                    label6.Text = "0 kbit\n0 kByte\n0-0";
                    comboBox1.Hide();
                    button1.Text = "Trennen";
                }
                catch (Exception)
                {

                }
            }
            else
            {
                if (port != null)
                {
                    try
                    {
                        port.Close();
                        Fehler(false);
                        verbergen();
                        verbergen2();
                        comboBox1.Show();
                        button1.Text = "Verbinden";
                    }
                    catch (Exception)
                    {
                    }

                }
            }
        }

        private void button2_Click(object sender, System.EventArgs e)
        {
            Fehler(false); 
            label4.Text = "0 Byte";
             label5.Text = "0 Byte";
             label6.Text = "0 kbit\n0 kByte\n0-0";

            if (port == null)
            {
                Fehler(true);
                button2.Show();
                return;
            }

            // Adresslänge ermitteln
            byte befehl = 69;
            byte[] temp = { befehl };
            port.Write(temp, 0, 1);

              byte a = (byte) port.ReadByte();
              byte b = (byte)port.ReadByte();
              byte c = (byte)port.ReadByte();

              byte adresslaenge = (byte)port.ReadByte();

              if (a != befehl || b != befehl || c != befehl || (adresslaenge == 0 || adresslaenge > 3))
              {
                  Fehler(true);
                  button2.Show();
                  return;
              }
              else
                  label4.Text = Convert.ToString(adresslaenge) + " Byte";


              // Seitengröße ermitteln
              befehl = 71;
              byte[] temp1 = { befehl, adresslaenge };
              port.Write(temp1, 0, 2);

              a = (byte)port.ReadByte();
              b = (byte)port.ReadByte();
              c = (byte)port.ReadByte();

              byte seitengroesse = (byte)port.ReadByte();

              if (a != befehl || b != befehl || c != befehl || (seitengroesse == 0))
              {
                  Fehler(true);
                  button2.Show();
                  return;
              }
              else
                  label5.Text = Convert.ToString(seitengroesse+1) + " Byte";


              // Speichergröße ermitteln
              befehl = 70;
              byte[] temp2 = { befehl , adresslaenge};
              port.Write(temp2, 0, 2);

              a = (byte)port.ReadByte();
              b = (byte)port.ReadByte();
              c = (byte)port.ReadByte();

              byte res2 = (byte)port.ReadByte();
              byte res1 = (byte)port.ReadByte();
              byte res0 = (byte)port.ReadByte();

              if (a != befehl || b != befehl || c != befehl || (res2 == 0 && res1 == 0 && res0 == 0))
              {
                  Fehler(true);
                  button2.Show();
                  return;
              }
              else{
                  int wert = ((res2 << 16) +(res1 << 8) +(res0) +1)*8/1000;
                  int wert2 = ((res2 << 16) +(res1 << 8) +(res0) +1)/1000;
                  int wert3 = ((res2 << 16) +(res1 << 8) +(res0));
                  label6.Text = Convert.ToString(wert) + " kbit\n"+
                      Convert.ToString(wert2) + " kByte\n"+
                       Convert.ToString(0)+"-"+Convert.ToString(wert3);
              }

              befehl = (byte) 'B';
              byte[] temp3 = { befehl};
              port.Write(temp3, 0, 1); System.Threading.Thread.Sleep(10);
              temp3[0] = adresslaenge; port.Write(temp3, 0, 1); System.Threading.Thread.Sleep(10);
              a = (byte)port.ReadByte();
               b = (byte)port.ReadByte();
               c = (byte)port.ReadByte();

               UInt16 seiten = (UInt16)(((res2 << 16) + (res1 << 8) + (res0) + 1) / (seitengroesse+1));

              temp3[0] = (byte)(seiten>>8); port.Write(temp3, 0, 1); System.Threading.Thread.Sleep(10);
              temp3[0] = (byte)(seiten); port.Write(temp3, 0, 1); System.Threading.Thread.Sleep(10);
              temp3[0] = seitengroesse; port.Write(temp3, 0, 1); System.Threading.Thread.Sleep(10);

                        int empf=0;
            int gute = 0;
            byte result=0;
            int bekommen = 0;
        bool ende=false;
            while (bekommen<seiten*2 && !ende){
                byte[] res = new byte[100];
                int h = 0;
                int anz = 0;
                try{
                h = port.BytesToRead; if (h > 100) h = 100;
                anz = port.Read(res, 0, h);
                   }
                catch (Exception)
                {
                }
                bekommen += anz;

                for (int i = 0; i < anz; i++)
                {
                    result = res[i];
                    if (result == 'O' || result == 'F') { ende = true; break; }

                  
                        if (result == 'S') empf++;
                        if (result == 'T') gute++;
                        label10.Text = "geschrieben: " + empf.ToString() + "/" + seiten.ToString() + "\ngelesen: " + gute.ToString() + "/" + seiten.ToString();
                        label10.Refresh();

                  
                }
            }

            if (result == 'O')
            {
                label10.Text="OK\n"+label10.Text;
            }
            else
                label10.Text = "Schlecht\n" + label10.Text;
            
        

        }

        private void Form1_FormClosing(object sender, FormClosingEventArgs e)
        {
            if (port != null)
            {
                try
                {
                    port.Close();
                }
                catch (Exception)
                {
                }

            }
        }

        int ReadDrei()
        {
            int a = port.ReadByte() << 16;
            int b = port.ReadByte() << 8; 
            int c = port.ReadByte();
            return a | b | c;
        }

        int ReadZwei()
        {
           int b = port.ReadByte() << 8;
            int c = port.ReadByte();
            return  b | c;
        }

        private void button4_Click(object sender, System.EventArgs e)
        {
            port.DiscardInBuffer();
            port.DiscardOutBuffer();

            // Kenndaten ermitteln
            byte befehl = 39;
            byte[] temp = { befehl };
            port.Write(temp, 0, 1);
         //  port.ReadTimeout = 5000;

            String[] Texte = { "Blockgröße",
                               "Blöcke insgesamt",

                               "A Adresslänge",
                               "B Adresslänge",
                               "C Adresslänge",
                                "D Adresslänge",
                               "A Seitengröße",
                                "B Seitengröße",
                                "C Seitengröße",
                                 "D Seitengröße",
                               "A Adressen",
                                "B Adressen",
                                 "C Adressen",
                                 "D Adressen",
                               "A Blöcke",
                                "B Blöcke",
                                 "C Blöcke",
                                   "D Blöcke",
                               "A Seiten",
                                "B Seiten",
                                 "C Seiten",
                                  "D Seiten",
                               "A Blöcke pro Seite",
                               "B Blöcke pro Seite",
                               "C Blöcke pro Seite",                              
                               "D Blöcke pro Seite",                              
                               "Zeitintervall"
                             };
            String[] Intervalle = { "1s", "5s","10s","30s","60s","150s","5m","10m","15m","30m","60m","90m","2h","6h","12h","24h"};
            try
            {
                port.ReadExisting();
                int breite = 100;
                listBox1.Items.Add(Texte[0] + ": " + Convert.ToString(port.ReadByte()));
                listBox1.Items.Add(Texte[1] + ": " + Convert.ToString(ReadDrei()));
                listBox1.Items.Add(("").PadLeft(breite, '-'));

                listBox1.Items.Add(Texte[2] + ": " + Convert.ToString(port.ReadByte()));
                listBox1.Items.Add(Texte[3] + ": " + Convert.ToString(port.ReadByte()));
                listBox1.Items.Add(Texte[4] + ": " + Convert.ToString(port.ReadByte()));
                listBox1.Items.Add(Texte[5] + ": " + Convert.ToString(port.ReadByte()));
                listBox1.Items.Add(("").PadLeft(breite, '-'));

                listBox1.Items.Add(Texte[6] + ": " + Convert.ToString(((int)port.ReadByte())+1));
                listBox1.Items.Add(Texte[7] + ": " + Convert.ToString(((int)port.ReadByte()) + 1));
                listBox1.Items.Add(Texte[8] + ": " + Convert.ToString(((int)port.ReadByte()) + 1));
                listBox1.Items.Add(Texte[9] + ": " + Convert.ToString(((int)port.ReadByte()) + 1));
                listBox1.Items.Add(("").PadLeft(breite, '-'));

                listBox1.Items.Add(Texte[10] + ": " + Convert.ToString(ReadDrei()));
                listBox1.Items.Add(Texte[11] + ": " + Convert.ToString(ReadDrei()));
                listBox1.Items.Add(Texte[12] + ": " + Convert.ToString(ReadDrei()));
                listBox1.Items.Add(Texte[13] + ": " + Convert.ToString(ReadDrei()));
                listBox1.Items.Add(("").PadLeft(breite, '-'));

                listBox1.Items.Add(Texte[14] + ": " + Convert.ToString(ReadDrei()));
                listBox1.Items.Add(Texte[15] + ": " + Convert.ToString(ReadDrei()));
                listBox1.Items.Add(Texte[16] + ": " + Convert.ToString(ReadDrei()));
                listBox1.Items.Add(Texte[17] + ": " + Convert.ToString(ReadDrei()));
                listBox1.Items.Add(("").PadLeft(breite, '-'));

                listBox1.Items.Add(Texte[18] + ": " + Convert.ToString(ReadZwei()));
                listBox1.Items.Add(Texte[19] + ": " + Convert.ToString(ReadZwei()));
                listBox1.Items.Add(Texte[20] + ": " + Convert.ToString(ReadZwei()));
                listBox1.Items.Add(Texte[21] + ": " + Convert.ToString(ReadZwei()));
                listBox1.Items.Add(("").PadLeft(breite, '-'));

                listBox1.Items.Add(Texte[22] + ": " + Convert.ToString(port.ReadByte()));
                listBox1.Items.Add(Texte[23] + ": " + Convert.ToString(port.ReadByte()));
                listBox1.Items.Add(Texte[24] + ": " + Convert.ToString(port.ReadByte()));
                listBox1.Items.Add(Texte[25] + ": " + Convert.ToString(port.ReadByte()));
                listBox1.Items.Add(("").PadLeft(breite, '-'));
                int a = port.ReadByte();
                String Text = "unbekannt";
                if (a>0)
                    Text =  Intervalle[a-1];
                listBox1.Items.Add(Texte[26] + ": " + Text);
            }
            catch (Exception) { listBox1.Items.Add("Fehler..."); listBox1.Refresh(); }

            }

        private void button5_Click(object sender, System.EventArgs e)
        {
            port.DiscardInBuffer();
            port.DiscardOutBuffer();

            // Datenstruktur anlegen
            byte []befehl = {33,34,35,36,37};
            byte[] temp = { befehl[comboBox2.SelectedIndex] };
            port.Write(temp, 0, 1);

            port.ReadTimeout = 30000;
            bool read=true;
            while (read){
                try
                {
                    byte a = (byte)port.ReadByte();
                    if (a == 'P')
                    {
                        listBox2.Items.Add("Beginne Baustein....");
                    }
                    else
                        if (a == 'Z')
                        {
                            listBox2.Items.Add("Abgeschlossen....");
                        }
                        else
                            if (a == 'S')
                            {
                                listBox2.Items.Add("Lese Seite....");
                            }
                            else
                                if (a == 'F')
                                {
                                    listBox2.Items.Add("Schreibkopf gesetzt....");
                                    read = false;
                                }
                    listBox2.Refresh();

                }
                catch (Exception)
                {
                    read = false;
                }
            } 

            
 
        }

        int blockgroesse = 0;
        int bloecke = 0;
        int sensoren = 0;
        int zeitintervall = 0;
        List<UInt64> result = new List<UInt64>();
        List<String> Log = new List<String>();

        public void Log_speichern(String Name)
        {
            StreamWriter datei = new StreamWriter("Logs/" + DateTime.Now.Year + "." + DateTime.Now.Month + "." + DateTime.Now.Day + " " + DateTime.Now.Hour + "." +DateTime.Now.Minute+"." + DateTime.Now.Second +"_" + Name + ".log");
            for (int i = 0; i < Log.Count; i++)
            {
                datei.WriteLine(Log[i]);
            }
            datei.Close();
            Log.Clear();
        }

        private void button3_Click(object sender, System.EventArgs e)
        {
            // Datenstruktur auslesen
            port.DiscardInBuffer();
            port.DiscardOutBuffer();

            byte befehl = 38;
            byte[] temp = { befehl };
            port.Write(temp, 0, 1);
            List<byte> data = new List<byte>();
           
            checkedListBox1.Items.Clear();
            checkedListBox1.Hide();

            label8.Text="Lese: 0000/0000";
            label8.Left = tabPage1.Width / 2 - label8.Width / 2;
            label8.Refresh();
            label8.Show();
            port.ReadTimeout = 10000;
           // port.ReadBufferSize = 10000;
          //  bool read = true;
                try
                {
                    zeitintervall = port.ReadByte();
                    Log.Add("Zeitintervall: " + zeitintervall);
                    blockgroesse = port.ReadByte();
                    Log.Add("Blockgrösse: " + blockgroesse);
                    sensoren = (blockgroesse * 8) / 11;
                    Log.Add("Sensoren: " + sensoren);
                    bloecke = ReadDrei();
                    Log.Add("Blöcke: " + bloecke);
                    label8.Text = "Lese: " + ("").PadLeft((bloecke * blockgroesse).ToString().Length, '0') + "/" + (bloecke * blockgroesse).ToString();
                    label8.Left = tabPage1.Width / 2 - label8.Width / 2;
                    label8.Refresh();

                    Log.Add("<<Originaldaten>>");
                    for (int i = 0; i < bloecke*blockgroesse;)
                    {
                            byte[] buffer = new byte[1000];
                            int h = port.BytesToRead; if (h > 1000) h = 1000;
                            int readed = port.Read(buffer, 0, h);
                            for (int f = 0; f < readed; f++)
                            {
                                data.Add(buffer[f]);
                                Log.Add(((int)buffer[f]).ToString());
                            }
                            i += readed;
                            label8.Text = "Lese: " + i.ToString().PadLeft((bloecke * blockgroesse).ToString().Length, '0') + "/" + (bloecke * blockgroesse).ToString();
                            label8.Left = tabPage1.Width / 2 - label8.Width / 2;
                            label8.Refresh();
                    }
                }
                catch (Exception)
                {
                }

                if (data.Count >= bloecke * blockgroesse)
                {

                    // Daten auswerten

                    // anfang finden
                    int last = 0;
                    int anfang = -1;
                    for (int i = blockgroesse - 1; i < bloecke * blockgroesse && anfang == -1; i += blockgroesse)
                    {
                        if (i == blockgroesse - 1)
                        {
                            last = data[i] & 1;
                        }
                        else
                        {
                            int dieses = data[i] & 1;
                            if (last == dieses)
                            {
                                anfang = i - (blockgroesse-1);
                                break;
                            }
                            last = dieses;
                        }
                    }
                    if (anfang == -1) anfang = 0;
                    Log.Add("Anfang: " + anfang);

                    // daten umsortieren
                    result = new List<UInt64>();
                    int schieb = blockgroesse * 8 - (11 * sensoren);

                    for (int i = anfang; i + blockgroesse <= (bloecke * blockgroesse); i += blockgroesse)
                    {
                        UInt64 dat = 0;
                        for (int b = 0; b < blockgroesse; b++)
                        {
                            dat = (UInt64)dat << 8;
                            dat |= (UInt64)data[i + b];
                        }
                        dat = (UInt64) dat >> schieb;
                        result.Add(dat);
                    }

                    for (int i = 0; i + blockgroesse <= anfang; i += blockgroesse)
                    {
                        UInt64 dat = 0;
                        for (int b = 0; b < blockgroesse; b++)
                        {
                            dat = (UInt64)dat << 8;
                            dat |= (UInt64)data[i + b];
                        }
                        dat = (UInt64) dat >> schieb;
                        result.Add(dat);
                    }

                    for (int i=0;i<sensoren;i++)
                        checkedListBox1.Items.Add("Sensor " + (i+ 1).ToString());

                    checkedListBox1.Show();
                }

                label8.Hide();
                Log_speichern("Auslesen");
        }

        private void checkedListBox1_ItemCheck(object sender, System.Windows.Forms.ItemCheckEventArgs e)
        {
            timer1.Enabled = true;
        }

        private void timer1_Tick(object sender, System.EventArgs e)
        {
            timer1.Enabled = false;
            String[] Intervalle = { "1s", "5s", "10s", "30s", "60s", "150s", "5m", "10m", "15m", "30m", "60m", "90m", "2h", "6h", "12h", "24h" };
            double[] ZeitIntervalle = { 1 / 60.0, 5 / 60.0, 10 / 60.0, 30 / 60.0, 60 / 60.0, 150 / 60.0, 300 / 60.0, 600 / 60.0, 900 / 60.0, 1800 / 60.0, 3600 / 60.0, 5400 / 60.0, 7200 / 60.0, 21600 / 60.0, 43200 / 60.0, 86400 / 60.0 };

            int anfang = 0;
            for (; anfang < result.Count; anfang++)
            {
                if (result[0] == 0)
                {
                    result.RemoveAt(0);
                }
                else
                    break;
            }
            anfang = 0;

            // chart anlegen
            chart1.Series.Clear();
            for (int z = 0; z < sensoren; z++)
            {
                if (!checkedListBox1.GetItemChecked(z)) continue;

                Series werte = new Series("Sensor " + (z + 1).ToString());
                werte.ChartType = SeriesChartType.Spline;


                double zeit = ZeitIntervalle[zeitintervall];
                float last = 0;
                bool abstand = false;
                int aktiv = 1;

                for (int i = anfang; i < result.Count; i++)
                {
                   // if (result[i] != 0)
                    //{
                        UInt64 messwert = (UInt64)result[i];
                        for (int b = 0; b < sensoren && b < z; b++)
                            messwert = (UInt64)messwert >> 11;

                        int mess = (UInt16)messwert;

                        mess = mess & 2047;
                        mess *= 125; mess /= 128;
                        mess -= 500;
                        float dat = mess / 10.0f;
                        if ((UInt16)messwert == 0 && abstand==false)
                        {
                            if (last>0)
                            {
                               // werte.Points.AddXY(zeit - 10, last);
                               // werte.Points.AddXY(zeit - 10, last-2);
                               // werte.Points.AddXY(zeit - 10, last);
                               // werte.Points.AddXY(zeit - 10, last+2);
                               // werte.Points.AddXY(zeit - 10, last);
                                abstand = true;
                                aktiv = 1;
                                zeit += ZeitIntervalle[zeitintervall];
                            }
                        }
                        else
                            if ((UInt16)messwert > 0)
                            {
                                if (aktiv>0)
                                {
                                    aktiv--;
                                }
                                else
                                if (abstand == true)
                                {
                                   
                                    int begin = werte.Points.Count - 1;
                                    for (double q = zeit - ZeitIntervalle[zeitintervall]; q <= zeit; q += ZeitIntervalle[zeitintervall])
                                    {
                                        werte.Points.AddXY(q, last);
                                        if (werte.Points.Count - 2!=begin) werte.Points[werte.Points.Count - 1].Color = Color.Red;

                                        werte.Points.AddXY(q, last - 1);
                                        werte.Points[werte.Points.Count - 1].Color = Color.Red;

                                        werte.Points.AddXY(q, last + 1);
                                        werte.Points[werte.Points.Count - 1].Color = Color.Red;

                                        werte.Points.AddXY(q, last);
                                        werte.Points[werte.Points.Count - 1].Color = Color.Red;

                             

                                        werte.Points.AddXY(q, dat);
                                        werte.Points[werte.Points.Count - 1].Color = Color.Red;

                                        werte.Points.AddXY(q, dat + 1);
                                        werte.Points[werte.Points.Count - 1].Color = Color.Red;

                                        werte.Points.AddXY(q, dat - 1 );
                                        werte.Points[werte.Points.Count - 1].Color = Color.Red;

                                    }

                                    werte.Points.AddXY(zeit, dat);
                                    werte.Points[werte.Points.Count - 1].Color = Color.Red;
                                    abstand = false;
                                    last = dat;
                                    zeit += ZeitIntervalle[zeitintervall];                       
                                }
                                else
                                    if (aktiv==0)
                                    {
                                        werte.Points.AddXY(zeit, dat);
                                        abstand = false;
                                        last = dat;
                                        zeit += ZeitIntervalle[zeitintervall];
                                    }

                                               
  

                    
                            }


                   // }
                }
                // werte.Points.AddXY(i + 1, Values[i]);

                ChartArea area = new ChartArea();
                area.AxisX.MinorGrid.Enabled = false;
                area.AxisX.MajorGrid.Enabled = false;
                area.AxisY.MinorGrid.Enabled = false;
                area.AxisY.MajorGrid.Enabled = false;

                Font font = new Font("Arial", 12, FontStyle.Bold);
                area.AxisX.Title = "Zeit in min";
                area.AxisX.TitleFont = font;
                area.AxisX.TitleAlignment = StringAlignment.Far;


                area.AxisY.Title = "°C";
                area.AxisY.TitleFont = font;

                area.AxisX.LabelStyle.Enabled = true;
                area.AxisX.LabelStyle.Angle = 30;
                area.AxisX.LabelStyle.Interval = 60;
                area.AxisX.LabelStyle.Format = "{0:0}min";

                area.AxisY.LabelStyle.Angle = 30;

                area.BackColor = Color.White;

                // chart1.Legends[0].BackColor = Color.Lavender;
                chart1.BackColor = Color.White;

                chart1.ChartAreas[0] = area;

                chart1.Series.Add(werte);
            }

            chart1.Show();
        }

        private void saveFileDialog1_FileOk(object sender, System.ComponentModel.CancelEventArgs e)
        {
            String dat = saveFileDialog1.FileName;
            if (Path.GetExtension(dat).ToUpper() != ".JPG")
                dat = Path.ChangeExtension(dat, ".JPG");

            chart1.SaveImage(dat, System.Drawing.Imaging.ImageFormat.Jpeg);

            if (Path.GetExtension(dat).ToUpper() != ".DAT")
             dat=   Path.ChangeExtension(dat, ".DAT");

            StreamWriter file = new StreamWriter(dat);
            file.WriteLine(blockgroesse.ToString());
            file.WriteLine(bloecke.ToString());
            file.WriteLine(sensoren.ToString());
            file.WriteLine(zeitintervall.ToString());

            int anfang = 0;
            for (; anfang < result.Count; anfang++)
            {
                if (result[anfang] != 0)
                    break;
            }

            for (int i = anfang; i < result.Count(); i++)
            {
                file.WriteLine(result[i].ToString());
            }
            file.Close();
        }

        private void Form1_KeyUp(object sender, System.Windows.Forms.KeyEventArgs e)
        {
            if (e.KeyData == Keys.S)
            {
                saveFileDialog1.ShowDialog();
            }
        }

        private void tabControl1_KeyUp(object sender, System.Windows.Forms.KeyEventArgs e)
        {
            if (e.KeyData == Keys.S)
            {
                saveFileDialog1.ShowDialog();
            }
        }

        private void button6_Click(object sender, System.EventArgs e)
        {
            saveFileDialog1.ShowDialog();
        }

        private void button7_Click(object sender, System.EventArgs e)
        {
            openFileDialog1.FileName = "";
            openFileDialog1.ShowDialog();
        }

        private void openFileDialog1_FileOk(object sender, System.ComponentModel.CancelEventArgs e)
        {
            String dat = openFileDialog1.FileName;
          //  if (Path.GetExtension(dat).ToUpper() != ".dat")
          //      Path.ChangeExtension(dat, ".dat");

            StreamReader file = new StreamReader(dat);
            blockgroesse = Convert.ToInt32(file.ReadLine());
            bloecke = Convert.ToInt32(file.ReadLine());
            sensoren = Convert.ToInt32(file.ReadLine());
            zeitintervall = Convert.ToInt32(file.ReadLine());
            result.Clear();

            while (!file.EndOfStream)
            {
                result.Add(Convert.ToUInt64(file.ReadLine()));
            }
            
            file.Close();

            checkedListBox1.Items.Clear();
            for (int i = 0; i < sensoren; i++)
                checkedListBox1.Items.Add("Sensor " + (i + 1).ToString());
            checkedListBox1.Show();
        }


        int anzahl = 0;
        String S14 = "";
        String S15 = "";
        String S16 = "";
        private void backgroundWorker1_DoWork(object sender, System.ComponentModel.DoWorkEventArgs e)
        {
             
            port.DiscardInBuffer();
            port.DiscardOutBuffer();

            while (port.ReadByte() != 'M') { }

            DateTime begin = DateTime.Now;
            DateTime Jetzt = DateTime.Now;
            for (int i = 0; i < anzahl; i++)
            {
                try
                {
                    port.ReadByte();
                    Jetzt = DateTime.Now;
                    S14 = Convert.ToString(i + 1);
                    TimeSpan temp = Jetzt - begin;
                    S15 = Convert.ToString(temp.Hours).PadLeft(2, '0') + ":" + Convert.ToString(temp.Minutes).PadLeft(2, '0') + ":" + Convert.ToString(temp.Seconds).PadLeft(2, '0') + ":" + Convert.ToString(temp.Milliseconds).PadLeft(3, '0');
                    temp = new TimeSpan((Jetzt - begin).Ticks / (i + 1));
                    S16 = Convert.ToString(temp.Hours).PadLeft(2, '0') + ":" + Convert.ToString(temp.Minutes).PadLeft(2, '0') + ":" + Convert.ToString(temp.Seconds).PadLeft(2, '0') + ":" + Convert.ToString(temp.Milliseconds).PadLeft(3, '0');
                }
                catch (Exception)
                {

                }
                }
        }

        private void button8_Click(object sender, System.EventArgs e)
        {
            port.DiscardInBuffer();
            port.DiscardOutBuffer();

            anzahl = Convert.ToInt32(comboBox3.Text);
            timer2.Enabled = true;
            backgroundWorker1.RunWorkerAsync();
        }

        private void timer2_Tick(object sender, System.EventArgs e)
        {
            label14.Text = S14;
                label15.Text = S15;
                label16.Text = S16;
        }



    }
}
