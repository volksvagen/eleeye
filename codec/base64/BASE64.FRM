VERSION 5.00
Begin VB.Form frmBase64 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Base64 Codec"
   ClientHeight    =   3195
   ClientLeft      =   45
   ClientTop       =   330
   ClientWidth     =   4680
   BeginProperty Font 
      Name            =   "����"
      Size            =   9
      Charset         =   134
      Weight          =   400
      Underline       =   0   'False
      Italic          =   0   'False
      Strikethrough   =   0   'False
   EndProperty
   MaxButton       =   0   'False
   OLEDropMode     =   1  'Manual
   ScaleHeight     =   3195
   ScaleWidth      =   4680
   StartUpPosition =   3  'Windows Default
   Begin VB.CommandButton btnLoad 
      Caption         =   "Load"
      Height          =   375
      Left            =   1440
      TabIndex        =   3
      Top             =   2760
      Width           =   855
   End
   Begin VB.TextBox txtCode 
      Height          =   2535
      Left            =   120
      MultiLine       =   -1  'True
      OLEDropMode     =   1  'Manual
      ScrollBars      =   2  'Vertical
      TabIndex        =   0
      Top             =   120
      Width           =   4455
   End
   Begin VB.CheckBox chkMultiLine 
      Caption         =   "MultiLine"
      Height          =   255
      Left            =   240
      TabIndex        =   2
      Top             =   2880
      Width           =   1215
   End
   Begin VB.CheckBox chkClipboard 
      Caption         =   "Clipboard"
      Height          =   255
      Left            =   240
      TabIndex        =   1
      Top             =   2640
      Width           =   1215
   End
   Begin VB.CommandButton btnExit 
      Cancel          =   -1  'True
      Caption         =   "Exit"
      Height          =   375
      Left            =   3360
      TabIndex        =   5
      Top             =   2760
      Width           =   855
   End
   Begin VB.CommandButton btnSave 
      Caption         =   "Save"
      Height          =   375
      Left            =   2400
      TabIndex        =   4
      Top             =   2760
      Width           =   855
   End
End
Attribute VB_Name = "frmBase64"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private Declare Function lstrlenA Lib "KERNEL32.DLL" (ByVal lpString As Long) As Long

Private Sub ReadFile(ByVal szFileName As String)

Dim i As Long, nFileLen As Long, nOpenFile As Integer
nOpenFile = FreeFile
On Error GoTo lnErrorOpen
Open szFileName For Binary Access Read As #nOpenFile
On Error GoTo 0
nFileLen = LOF(nOpenFile)
ReDim ucData(1 To nFileLen) As Byte
ReDim ucText(1 To (nFileLen \ 33 + 1) * 46) As Byte
For i = 1 To nFileLen
    Get #nOpenFile, , ucData(i)
Next
Base64Enc VarPtr(ucText(1)), VarPtr(ucData(1)), nFileLen, chkMultiLine.Value * 11
txtCode.Text = MkBStr(VarPtr(ucText(1)))
Erase ucText
Erase ucData
Close #nOpenFile

Exit Sub
lnErrorOpen:
MsgBox "Cannot Read File " + szFileName, vbExclamation
On Error GoTo 0

End Sub

Private Sub ReadClipboard(ByVal sz As String)

Dim i As Long, nFileLen As Long

nFileLen = lstrlenA(StrPtr(sz))
ReDim ucText(1 To (nFileLen \ 33 + 1) * 46) As Byte
Base64Enc VarPtr(ucText(1)), StrPtr(sz), nFileLen, chkMultiLine.Value * 11
txtCode.Text = MkBStr(VarPtr(ucText(1)))
Erase ucText

End Sub

Private Sub Form_Load()

Dim sz As String
sz = Command
If sz <> "" Then
    If Left(sz, 1) = """" And Right(sz, 1) = """" Then
        sz = Mid(sz, 2, Len(sz) - 2)
    End If
    ReadFile sz
End If

End Sub

Private Sub Form_OLEDragDrop(data As DataObject, effect As Long, button As Integer, shift As Integer, x As Single, y As Single)

If data.GetFormat(vbCFFiles) Then
    ReadFile data.Files(1)
End If

End Sub

Private Sub btnLoad_Click()

Dim sz As String
Dim i As Long, nFileLen As Long, nOpenFile As Integer
If chkClipboard.Value = 0 Then
    sz = OpenFileDialog("Load Binary File", "Binary File (*.*)|*.*")
    If sz <> "" Then
        ReadFile sz
    End If
Else
    sz = Clipboard.GetText
    If sz <> "" Then
        ReadClipboard sz
    End If
End If

End Sub

Private Sub btnSave_Click()

Dim i As Long, nLen As Long, nOpenFile As Integer, sz As String
If chkClipboard.Value = 0 Then
    sz = SaveFileDialog("Load Binary File", "Binary File (*.*)|*.*", "")
    If sz <> "" Then
        nOpenFile = FreeFile
        On Error GoTo lnErrorOpen
        Open sz For Binary Access Write As #nOpenFile
        On Error GoTo 0
        ReDim ucData(1 To (Len(txtCode.Text) \ 4 + 1) * 3) As Byte
        nLen = Base64Dec(VarPtr(ucData(1)), CvBStr("" + txtCode.Text))
        For i = 1 To nLen
            Put #nOpenFile, , ucData(i)
        Next
        Erase ucData
        Close #nOpenFile
    End If
Else
    ReDim ucData(0 To (Len(txtCode.Text) \ 4 + 1) * 3) As Byte
    nLen = Base64Dec(VarPtr(ucData(0)), CvBStr("" + txtCode.Text))
    ucData(nLen) = 0
    Clipboard.Clear
    Clipboard.SetText MkBStr(VarPtr(ucData(0)))
    Erase ucData
End If

Exit Sub
lnErrorOpen:
MsgBox "Cannot Write File " + sz, vbExclamation
On Error GoTo 0

End Sub

Private Sub btnExit_Click()

Unload Me

End Sub

Private Sub txtCode_OLEDragDrop(data As DataObject, effect As Long, button As Integer, shift As Integer, x As Single, y As Single)

If data.GetFormat(vbCFFiles) Then
    ReadFile data.Files(1)
End If

End Sub
