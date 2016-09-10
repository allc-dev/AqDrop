unit AqDrop.DB.Tokenizer;

interface

uses
  AqDrop.Core.Tokenizer,
  AqDrop.Core.Automaton,
  AqDrop.Core.Automaton.Text;

type
  TAqDBTokenizerDictionaryID = (diOther, diDigits, diCharacters, diPlus, diMinus, diAsterisk, diSlash, diSharp,
    idUnderscore, diSemicolon, diComma, diColon, diLeftParenthesis, diRightParenthesis, diSpace, diDot,
    di10, di13, diSingleQuotes, diDoubleQuotes, diInterrogation, diEqual, diAt);

const
  TAqDBTokenizerDictionaryMin = diOther;
  TAqDBTokenizerDictionaryMax = diAt;

  TAqDBTokenizerDicionaries: array[TAqDBTokenizerDictionaryMin..TAqDBTokenizerDictionaryMax] of set of AnsiChar = (
    [#0], ['0'..'9'], ['A'..'Z', 'a'..'z'], ['+'], ['-'], ['*'], ['/'], ['#'], ['_'], [';'], [','], [':'], ['('], [')'],
    [' '], ['.'], [#10], [#13], [''''], ['"'], ['?'], ['='], ['@']);

type
  TAqDBTokenType = (ttOther, ttWord, ttInteger, ttReal, ttSpace, ttLineBreak, ttComment, ttMultiplication, ttDivision,
    ttAddition, ttSubtraction, ttLeftParenthesis, ttRightParenthesis, ttComma, ttSemicolon, ttColon, ttString,
    ttParameter, ttNamedParameter, ttEqual, ttDot, ttAt);

  /// <summary>
  ///   Tokenizer para sentenšas SQL.
  /// </summary>
  TAqBDTokenizer = class(TAqTokenizer<TAqDBTokenizerDictionaryID, TAqDBTokenType>)
  strict private
    class var FInstance: TAqBDTokenizer;
    constructor Create;
  public
    class destructor Destroy;
    class function GetInstance: TAqBDTokenizer;
  end;

implementation

{ TAqBDTokenizer }

constructor TAqBDTokenizer.Create;
type
  TTransition = TAqAutomatonTransition<TAqDBTokenizerDictionaryID, Char, TAqDBTokenType>;
  TState = TAqAutomatonState<TAqDBTokenizerDictionaryID, Char, TAqDBTokenType>;
var
  lTransition: TTransition;
  lFinalStateSpace: TState;
  lFinalStateWord: TState;
  lFinalStateInteger: TState;
  lIntermediateStateDot: TState;
  lFinalStateReal: TState;
  lIntermediateStateLineBreak: TState;
  lFinalStateLineBreak: TState;
  lFinalStateDivision: TState;
  lFinalStateAddition: TState;
  lFinalStateSubtraction: TState;
  lFinalStateMultiplication: TState;
  lFinalStateCommentLine1: TState;
  lFinalStateCommentLine2: TState;
  lFinalStateCommentLine3: TState;
  lIntermediateStateComment1: TState;
  lIntermediateStateComment2: TState;
  lFinalStateComment: TState;
  lFinalStateLeftParenthesis: TState;
  lFinalStateRightParenthesis: TState;
  lFinalStateComma: TState;
  lFinalStateSemicolon: TState;
  lIntermediateStateString: TState;
  lFinalStateString: TState;
  lIntermediateStateDoubleQuotes: TState;
  lFinalSteteDoubleQuotes: TState;
  lFinalStateColon: TState;
  lFinalStateNamedParameter: TState;
  lFinalStateParameter: TState;
  lFianlStateEqual: TState;
  lFinalStateDot: TState;
  lFinalStateAt: TState;
  lDictionaryID: TAqDBTokenizerDictionaryID;
begin
  inherited;

  for lDictionaryID := TAqDBTokenizerDictionaryMin to TAqDBTokenizerDictionaryMax do
  begin
    Automaton.AddDictionary(lDictionaryID, TAqDBTokenizerDicionaries[lDictionaryID]);
  end;

  lFinalStateSpace := Automaton.AddFinalState(ttSpace);
  lTransition := Automaton.InitialState.AddTransition(lFinalStateSpace);
  lTransition.AddDictionary(diSpace);

  lFinalStateWord := Automaton.AddFinalState(ttWord);
  lTransition := Automaton.InitialState.AddTransition(lFinalStateWord);
  lTransition.AddDictionary(diCharacters);
  lTransition := lFinalStateWord.AddTransition(lFinalStateWord);
  lTransition.AddDictionary(diCharacters);
  lTransition.AddDictionary(diDigits);
  lTransition.AddDictionary(idUnderscore);

  lFinalStateInteger := Automaton.AddFinalState(ttInteger);
  lTransition := Automaton.InitialState.AddTransition(lFinalStateInteger);
  lTransition.AddDictionary(diDigits);
  lTransition := lFinalStateInteger.AddTransition(lFinalStateInteger);
  lTransition.AddDictionary(diDigits);
  lIntermediateStateDot := Automaton.AddIntermediateState;
  lTransition := lFinalStateInteger.AddTransition(lIntermediateStateDot);
  lTransition.AddDictionary(diDot);
  lFinalStateReal := Automaton.AddFinalState(ttReal);
  lTransition := lIntermediateStateDot.AddTransition(lFinalStateReal);
  lTransition.AddDictionary(diDigits);
  lTransition := lFinalStateReal.AddTransition(lFinalStateReal);
  lTransition.AddDictionary(diDigits);

  lIntermediateStateLineBreak := Automaton.AddIntermediateState;
  Automaton.InitialState.AddTransition(lIntermediateStateLineBreak).AddDictionary(di13);
  lFinalStateLineBreak := Automaton.AddFinalState(ttLineBreak);
  lIntermediateStateLineBreak.AddTransition(lFinalStateLineBreak).AddDictionary(di10);

  lFinalStateAddition := Automaton.AddFinalState(ttAddition);
  Automaton.InitialState.AddTransition(lFinalStateAddition).AddDictionary(diPlus);

  lFinalStateSubtraction := Automaton.AddFinalState(ttSubtraction);
  Automaton.InitialState.AddTransition(lFinalStateSubtraction).AddDictionary(diMinus);

  lFinalStateMultiplication := Automaton.AddFinalState(ttMultiplication);
  Automaton.InitialState.AddTransition(lFinalStateMultiplication).AddDictionary(diAsterisk);

  lFinalStateDivision := Automaton.AddFinalState(ttDivision);
  Automaton.InitialState.AddTransition(lFinalStateDivision).AddDictionary(diSlash);

  lFinalStateCommentLine1 := Automaton.AddFinalState(ttComment);
  lFinalStateSubtraction.AddTransition(lFinalStateCommentLine1).AddDictionary(diMinus);
  lFinalStateCommentLine1.AddTransition(lFinalStateCommentLine1).AddDictionary(diOther);
  lFinalStateCommentLine2 := Automaton.AddFinalState(ttComment);
  lFinalStateCommentLine1.AddTransition(lFinalStateCommentLine2).AddDictionary(di13);
  lFinalStateCommentLine2.AddTransition(lFinalStateCommentLine1).AddDictionary(diOther);
  lFinalStateCommentLine3 := Automaton.AddFinalState(ttComment);
  lFinalStateCommentLine2.AddTransition(lFinalStateCommentLine3).AddDictionary(di10);

  lIntermediateStateComment1 := Automaton.AddIntermediateState;
  lFinalStateDivision.AddTransition(lIntermediateStateComment1).AddDictionary(diAsterisk);
  lIntermediateStateComment1.AddTransition(lIntermediateStateComment1).AddDictionary(diOther);
  lIntermediateStateComment2 := Automaton.AddIntermediateState;
  lIntermediateStateComment1.AddTransition(lIntermediateStateComment2).AddDictionary(diAsterisk);
  lIntermediateStateComment2.AddTransition(lIntermediateStateComment2).AddDictionary(diAsterisk);
  lIntermediateStateComment2.AddTransition(lIntermediateStateComment1).AddDictionary(diOther);
  lFinalStateComment := Automaton.AddFinalState(ttComment);
  lIntermediateStateComment2.AddTransition(lFinalStateComment).AddDictionary(diSlash);

  lFinalStateLeftParenthesis := Automaton.AddFinalState(ttLeftParenthesis);
  Automaton.InitialState.AddTransition(lFinalStateLeftParenthesis).AddDictionary(diLeftParenthesis);

  lFinalStateRightParenthesis := Automaton.AddFinalState(ttRightParenthesis);
  Automaton.InitialState.AddTransition(lFinalStateRightParenthesis).AddDictionary(diRightParenthesis);

  lFinalStateComma := Automaton.AddFinalState(ttComma);
  Automaton.InitialState.AddTransition(lFinalStateComma).AddDictionary(diComma);

  lFinalStateSemicolon := Automaton.AddFinalState(ttSemicolon);
  Automaton.InitialState.AddTransition(lFinalStateSemicolon).AddDictionary(diSemicolon);

  lIntermediateStateString := Automaton.AddIntermediateState;
  Automaton.InitialState.AddTransition(lIntermediateStateString).AddDictionary(diSingleQuotes);
  lIntermediateStateString.AddTransition(lIntermediateStateString).AddDictionary(diOther);
  lFinalStateString := Automaton.AddFinalState(ttString);
  lIntermediateStateString.AddTransition(lFinalStateString).AddDictionary(diSingleQuotes);
  lFinalStateString.AddTransition(lIntermediateStateString).AddDictionary(diSingleQuotes);

  lIntermediateStateDoubleQuotes := Automaton.AddIntermediateState;
  Automaton.InitialState.AddTransition(lIntermediateStateDoubleQuotes).AddDictionary(diDoubleQuotes);
  lIntermediateStateDoubleQuotes.AddTransition(lIntermediateStateDoubleQuotes).AddDictionary(diOther);
  lFinalSteteDoubleQuotes := Automaton.AddFinalState(ttString);
  lIntermediateStateDoubleQuotes.AddTransition(lFinalSteteDoubleQuotes).AddDictionary(diDoubleQuotes);
  lFinalSteteDoubleQuotes.AddTransition(lIntermediateStateDoubleQuotes).AddDictionary(diDoubleQuotes);

  lFinalStateColon := Automaton.AddFinalState(ttColon);
  Automaton.InitialState.AddTransition(lFinalStateColon).AddDictionary(diColon);

  lFinalStateNamedParameter := Automaton.AddFinalState(ttNamedParameter);
  lFinalStateColon.AddTransition(lFinalStateNamedParameter).AddDictionary(diCharacters);
  lTransition := lFinalStateNamedParameter.AddTransition(lFinalStateNamedParameter);
  lTransition.AddDictionary(diCharacters);
  lTransition.AddDictionary(diDigits);
  lTransition.AddDictionary(idUnderscore);

  lFinalStateParameter := Automaton.AddFinalState(ttParameter);
  Automaton.InitialState.AddTransition(lFinalStateParameter).AddDictionary(diInterrogation);

  lFianlStateEqual := Automaton.AddFinalState(ttEqual);
  Automaton.InitialState.AddTransition(lFianlStateEqual).AddDictionary(diEqual);

  lFinalStateDot := Automaton.AddFinalState(ttDot);
  Automaton.InitialState.AddTransition(lFinalStateDot).AddDictionary(diDot);

  lFinalStateAt := Automaton.AddFinalState(ttAt);
  Automaton.InitialState.AddTransition(lFinalStateAt).AddDictionary(diAt);
end;

class destructor TAqBDTokenizer.Destroy;
begin
  FInstance.Free;
end;

class function TAqBDTokenizer.GetInstance: TAqBDTokenizer;
begin
  if not Assigned(FInstance) then
  begin
    FInstance := TAqBDTokenizer.Create;
  end;

  Result := FInstance;
end;

end.
