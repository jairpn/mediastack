unit uPrincipal;

interface

uses
    System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
    FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
    FMX.Effects, FMX.Layouts, FMX.Ani, FMX.Objects,
    FMX.Controls.Presentation, REST.Types, REST.Client, Data.Bind.Components,
    Data.Bind.ObjectScope, System.JSON, System.Generics.Collections,
    System.Net.URLClient, System.Net.HttpClient, System.Net.HttpClientComponent,
    REST.Authenticator.Simple;

type
    TForm11 = class(TForm)
        ToolBar1: TToolBar;
        SpeedButton1: TSpeedButton;
        SpeedButton2: TSpeedButton;
        Label1: TLabel;
        vrtscrlbx1: TVertScrollBox;
        StyleBook1: TStyleBook;
        RESTClient1: TRESTClient;
        RESTRequest1: TRESTRequest;
        RESTResponse1: TRESTResponse;
        procedure SpeedButton2Click(Sender: TObject);
        procedure SpeedButton1Click(Sender: TObject);
        procedure FormCreate(Sender: TObject);
        private
            { Private declarations }
            // runtime components for news card
            Retangulo: TRectangle;
            NovaImagem: TImage;
            Titulo: TLabel;
            TituloDescritivo: TLabel;
            // save runtime components to the list
            RctList: TList<TRectangle>;
            ImgList: TList<TImage>;
            LblTitleList: TList<TLabel>;
            LblDescpList: TList<TLabel>;
        public
            { Public declarations }
            procedure buscaNews;
    end;

var
      Form11: TForm11;

implementation

{$R *.fmx}


uses Loading;

procedure TForm11.buscaNews;
begin

//    RESTClient1.BaseURL := '';

//    RESTClient1.BaseURL := 'https://newsapi.org/v2/everything?q=tesla&from=2021-07-15&sortBy=publishedAt&apiKey=e3b8cdef2b87487190aa93663665bbff';

    RESTRequest1.Execute; // send request to endpoint

    var JSONValue: TJSONValue;

    var JSONArray: TJSONArray;

    var ArrayElement: TJSONValue;

    var contador: integer;

    contador := 0;

    // after using object we just free them within the Lists
    RctList := TList<TRectangle>.Create;
    ImgList := TList<TImage>.Create;
    LblTitleList := TList<TLabel>.Create;
    LblDescpList := TList<TLabel>.Create;

    try
        JSONValue := TJSONObject.ParseJSONValue(RESTResponse1.Content);
        JSONArray := JSONValue.GetValue<TJSONArray>('articles'); // articles are stored in the data array in the JSON response

        for ArrayElement in JSONArray do
            begin
                inc(contador);
                if (contador = 6) then
                    exit;

                {$REGION 'Create news card' }
                Retangulo := TRectangle.Create(vrtscrlbx1);
                Retangulo.Parent := vrtscrlbx1;
                Retangulo.HitTest := False;
                Retangulo.Fill.Color := TAlphaColorRec.Ghostwhite;
                Retangulo.Fill.Kind := TBrushKind.Solid;
                Retangulo.Stroke.Thickness := 0;
                Retangulo.Align := TAlignLayout.Top;
                Retangulo.Height := 400;
                Retangulo.Width := 389;
                Retangulo.XRadius := 15;
                Retangulo.YRadius := 15;
                Retangulo.Margins.Top := 5;
                Retangulo.Margins.Bottom := 5;
                Retangulo.Margins.Left := 5;
                Retangulo.Margins.Right := 5;
                RctList.Add(Retangulo); // add to the TList instance
                {$ENDREGION}
                {$REGION 'create image and load image from the url' }
                NovaImagem := TImage.Create(Retangulo);
                NovaImagem.Parent := Retangulo;
                NovaImagem.HitTest := False;
                NovaImagem.Align := TAlignLayout.Top;
                NovaImagem.Height := 225;
                NovaImagem.Width := 389;
                NovaImagem.Margins.Top := 5;
                NovaImagem.Margins.Left := 15;
                NovaImagem.Margins.Right := 15;
                NovaImagem.Margins.Bottom := 0;
                NovaImagem.HitTest := False;
                NovaImagem.MarginWrapMode := TImageWrapMode.Stretch;
                NovaImagem.WrapMode := TImageWrapMode.Fit;
                ImgList.Add(NovaImagem);

                // load images to the newly created TImage component
                var
                MemoryStream := TMemoryStream.Create;
                var
                HttpClient := TNetHTTPClient.Create(nil);
                var
                HTTPRequest := TNetHTTPRequest.Create(nil);
                HTTPRequest.Client := HttpClient;
                try
                    var
                    ImageURL := ArrayElement.GetValue<String>('urlToImage');
                    HTTPRequest.Get(ImageURL, MemoryStream);
                    MemoryStream.Seek(0, soFromBeginning);
                    NovaImagem.Bitmap.LoadFromStream(MemoryStream);
                finally
                    FreeAndNil(MemoryStream);
                    FreeAndNil(HttpClient);
                    FreeAndNil(HTTPRequest);
                end;
                {$ENDREGION}
                {$REGION 'create title and summary texts in the News Card' }
                Titulo := TLabel.Create(Retangulo);
                Titulo.Parent := Retangulo;
                Titulo.Align := TAlignLayout.Top;
                Titulo.Height := 27;
                Titulo.Width := 359;
                Titulo.HitTest := False;
                Titulo.AutoSize := True;
                Titulo.Font.Size := 22;
                Titulo.Margins.Left := 15;
                Titulo.Margins.Right := 15;
                Titulo.Margins.Top := 5;
                Titulo.Margins.Bottom := 5;
                Titulo.Text := ArrayElement.GetValue<String>('title'); // 'Title: ' + ArrayElement.GetValue<String>('title');
                LblTitleList.Add(Titulo);
                TituloDescritivo := TLabel.Create(Retangulo);
                TituloDescritivo.Parent := Retangulo;
                TituloDescritivo.Align := TAlignLayout.Client;
                TituloDescritivo.Height := 131;
                TituloDescritivo.Width := 359;
                TituloDescritivo.HitTest := False;
                TituloDescritivo.AutoSize := True;
                TituloDescritivo.Font.Size := 15;
                TituloDescritivo.Margins.Left := 15;
                TituloDescritivo.Margins.Right := 15;
                TituloDescritivo.Margins.Top := 5;
                TituloDescritivo.Margins.Bottom := 5;
                TituloDescritivo.Text := ArrayElement.GetValue<String>('description');
                LblDescpList.Add(TituloDescritivo);
                {$ENDREGION}
            end;

    finally
        RctList.Free;
        ImgList.Free;
        LblTitleList.Free;
        LblDescpList.Free;
    end;
end;

procedure TForm11.FormCreate(Sender: TObject);
begin

 buscaNews;

{*    TLoading.Show(Form11, 'Aguarde..');
    TThread.CreateAnonymousThread(procedure
        begin
            sleep(1000);
            buscaNews;
            TThread.Synchronize(nil, procedure
                begin
                    TLoading.Hide;
                end);
        end).Start;     *}
end;

procedure TForm11.SpeedButton1Click(Sender: TObject);
begin
    Application.Terminate;
end;

procedure TForm11.SpeedButton2Click(Sender: TObject);
begin
    TLoading.Show(Form11, 'Aguarde..');
    TThread.CreateAnonymousThread(procedure
        begin
            sleep(1000);
            buscaNews;
            TThread.Synchronize(nil, procedure
                begin
                    TLoading.Hide;
                end);
        end).Start;

end;

end.
