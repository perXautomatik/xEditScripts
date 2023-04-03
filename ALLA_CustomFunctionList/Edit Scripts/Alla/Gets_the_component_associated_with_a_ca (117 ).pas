
// Gets the component associated with a caption
function AssociatedComponent(s: String; frm: TForm): TObject;
begin
	Result := ComponentByTop(ComponentByCaption(s, frm).Top - 2, frm)
end;