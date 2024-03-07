{*
 *  Copyright (C) 2024  Uwe Merker
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 *}
unit Dpb_Calc;

{$mode objfpc}
{$H+}

interface

uses
    SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls, ComCtrls;

type

    { TformDpbCalc }

    TformDpbCalc = class(TForm)
        buttonCalculate: TButton;
        comboboxBlockSize: TComboBox;
        comboboxSecLen: TComboBox;
        editSpt: TEdit;
        editBsh: TEdit;
        editPsh: TEdit;
        editPhm: TEdit;
        editBlm: TEdit;
        editExm: TEdit;
        editDsm: TEdit;
        editDrm: TEdit;
        editAl0: TEdit;
        editAL1: TEdit;
        editCks: TEdit;
        editOff: TEdit;
        editTracks: TEdit;
        editSecTrk: TEdit;
        editMaxDir: TEdit;
        editBootTrk: TEdit;
        labelSpt: TLabel;
        labelSecLen: TLabel;
        labelBsh: TLabel;
        labelPsh: TLabel;
        labelPhm: TLabel;
        labelBlm: TLabel;
        labelExm: TLabel;
        labelDsm: TLabel;
        labelDrm: TLabel;
        labelAl0: TLabel;
        labelAl1: TLabel;
        labelCks: TLabel;
        labelOff: TLabel;
        labelTracks: TLabel;
        labelSecTrk: TLabel;
        labelBlockSize: TLabel;
        labelMaxDir: TLabel;
        labelBootTrk: TLabel;
        panelSpt: TPanel;
        panelDpbValues: TPanel;
        panelBsh: TPanel;
        panelPsh: TPanel;
        panelPhm: TPanel;
        panelBlm: TPanel;
        panelExm: TPanel;
        panelDsm: TPanel;
        panelDrm: TPanel;
        panelAl0: TPanel;
        panelAl1: TPanel;
        panelCks: TPanel;
        panelOff: TPanel;
        panelStartCalc: TPanel;
        panelDiskDefs: TPanel;
        panelSecLen: TPanel;
        panelTracks: TPanel;
        panelSecTrk: TPanel;
        panelBlockSize: TPanel;
        panelMaxDir: TPanel;
        panelBootTrk: TPanel;
        StatusBar: TStatusBar;
        procedure buttonCalculateClick(Sender: TObject);
        procedure FormShow(Sender: TObject);
    private
    type
        TAlv = packed record
            case byte of
                0: (Value: word);
                1: (al1: byte;
                    al0: byte);
        end;

    public

    end;

var
    formDpbCalc: TformDpbCalc;

implementation

{$R *.lfm}

{ TformDpbCalc }

uses Math;

// --------------------------------------------------------------------------------
procedure TformDpbCalc.FormShow(Sender: TObject);
begin
    self.SetAutoSize(True);
    Constraints.MinWidth := Width;
    Constraints.MaxWidth := Width;
    Constraints.MinHeight := Height;
    Constraints.MaxHeight := Height;
end;

// --------------------------------------------------------------------------------
procedure TformDpbCalc.buttonCalculateClick(Sender: TObject);
var
    seclen, tracks, sectrk, blocksize, maxdir, boottrk: dword;
    spt, bsh, blm, exm, dsm, drm, dav, cks, psh, phm: dword;
    alv: TAlv;
    Count: dword;
begin
    seclen := StrToInt(comboboxSecLen.Items[comboboxSecLen.ItemIndex]);
    tracks := StrToInt(editTracks.Text);
    sectrk := StrToInt(editSecTrk.Text);
    blocksize := StrToInt(comboboxBlockSize.Items[comboboxBlockSize.ItemIndex]);
    maxdir := StrToInt(editMaxDir.Text);
    boottrk := StrToInt(editBootTrk.Text);

    spt := ((seclen div 128) * sectrk);
    bsh := Round(Log2(blocksize div 128));
    blm := ((blocksize div 128) - 1);

    dsm := (((seclen * (tracks - boottrk) * sectrk) div blocksize) - 1);

    if ((dsm > 32767) or ((blocksize = 1024) and (dsm > 255))) then begin
        editDsm.Color := clRed;
    end
    else begin
        editDsm.Color := clDefault;
    end;

    case (blocksize) of

        512: exm := 0;

        1024: exm := 0;

        2048: begin

            if (dsm < 256) then begin
                exm := 1;
            end
            else begin
                exm := 0;
            end;

        end;

        4096: begin

            if (dsm < 256) then begin
                exm := 3;
            end
            else begin
                exm := 1;
            end;

        end;
        8192: begin

            if (dsm < 256) then begin
                exm := 7;
            end
            else begin
                exm := 3;
            end;

        end;

        16384: begin

            if (dsm < 256) then begin
                exm := 15;
            end
            else begin
                exm := 7;
            end;

        end;
    end;

    drm := (maxdir - 1);

    if (drm > (((blocksize div 32) * 16) - 1)) then begin
        editDrm.Color := clRed;
    end
    else begin
        editDrm.Color := clDefault;
    end;

    dav := ((drm + 1) div (blocksize div 32));

    if (dav > 16) then begin
        editAl0.Color := clRed;
        editAL1.Color := clRed;
    end
    else begin
        editAl0.Color := clDefault;
        editAL1.Color := clDefault;
    end;

    alv.Value := 0;

    for Count := 0 to dav do begin
        alv.Value := alv.Value + (1 shl (16 - Count));
    end;

    cks := ((drm div 4) + 1);

    case (seclen) of

        128: begin
            psh := 0;
            phm := 0;
        end;

        256: begin
            psh := 1;
            phm := 1;
        end;

        512: begin
            psh := 2;
            phm := 3;
        end;

        1024: begin
            psh := 3;
            phm := 7;
        end;

        2048: begin
            psh := 4;
            phm := 15;
        end;

        4096: begin
            psh := 5;
            phm := 31;
        end;

    end;

    editSpt.Text := IntToStr(spt);
    editBsh.Text := IntToStr(bsh);
    editBlm.Text := IntToStr(blm);
    editExm.Text := IntToStr(exm);
    editDsm.Text := IntToStr(dsm);
    editDrm.Text := IntToStr(drm);
    editAl0.Text := IntToStr(alv.al0);
    editAl1.Text := IntToStr(alv.al1);
    editCks.Text := IntToStr(cks);
    editOff.Text := IntToStr(boottrk);
    editPsh.Text := IntToStr(psh);
    editPhm.Text := IntToStr(phm);

end;

// --------------------------------------------------------------------------------
end.
