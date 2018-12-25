require 'rspec'

describe 'Pattern Matching tests' do
  context 'de variable' do
    it 'se cumple siempre' do
      expect(:a_variable_name.call('anything')).to be true
    end
  end

  context 'de valor' do
    it 'un numero es igual a mismo numero' do
      expect(val(7).call(7)).to be true
    end
    it 'un numero no es igual a otr numero' do
      expect(val(7).call(8)).to be false
    end
    it 'un numero no es igual a un string' do
      expect(val(7).call('7')).to be false
    end
  end

  describe 'de tipo' do
    it 'un integer es un numero' do
      expect(type(Integer).call(5)).to be true
    end
    it 'un symbol no es un string' do
      expect(type(Symbol).call("Trust me, I'm a Symbol..")).to be false
    end
    it 'un symbol no es un symbol' do
      expect(type(Symbol).call(:a_real_symbol)).to be true
    end

    it 'un string es un string' do
      expect(type(String).call("hola")).to be true
    end
  end

  context 'de array' do
    let(:an_array) {[1, 2, 3, 4]}

    it 'un array igual de mismo size y match_size true' do
      expect(list([1, 2, 3, 4], true).call(an_array)).to be true
    end

    it 'un array igual de mismo size y match_size false' do
      expect(list([1, 2, 3, 4], false).call(an_array)).to be true
    end

    it 'un array igual de distinto size y match_size true' do
      expect(list([1, 2, 3], true).call(an_array)).to be false
    end

    it 'un array igual de distinto size y match_size false' do
      expect(list([1, 2, 3], false).call(an_array)).to be true
    end

    it 'un array distinto y match_size true' do
      expect(list([4, 1, 2, 3], true).call(an_array)).to be false
    end

    it 'un array distinto y match_size false' do
      expect(list([4, 1, 2, 3], false).call(an_array)).to be false
    end

    it 'array combinado con el Matcher de variables' do
      expect(list([:a, :b, :c, :d]).call(an_array)).to be true
    end

  end

  context 'de duck typing' do
    psyduck = Object.new
    before do
      def psyduck.cuack
        'psy..duck?'
      end

      def psyduck.fly
        '(headache)'
      end
    end

    class Dragon
      def fly
        'do some flying'
      end
    end
    a_dragon = Dragon.new

    it 'un object que entiende los siguientes metodos' do
      print(psyduck.class.instance_methods.include?(:fly))
      psyduck.cuack
      expect(duck(:cuack, :fly).call(psyduck)).to be true
    end

    it 'un objeto que no entiendo los siguientes metodos' do
      expect(duck(:cuack, :fly).call(a_dragon)).to be false
    end

    it 'una instancia de una clase entiende sus metodos' do
      expect(duck(:fly).call(a_dragon)).to be true
    end

    it 'una instancia de una clase entiende sus methodos' do
      expect(duck(:to_s).call(Object.new)).to be true
    end

    it 'un string entiende sus methodos' do
      expect(duck(:length).call("hola")).to be true
      expect(duck(:==).call("hola")).to be true
      expect(duck(:length, :==).call("hola")).to be true
      expect(duck(:lalala).call("hola")).to be false
    end

  end

  context 'combinators' do
    context 'and' do
      it {expect(type(Object).and(type(Integer)).call(5)).to be true}
      it {expect(type(Symbol).and(type(Integer)).call(5)).to be false}
      it {expect(type(Integer).and(type(Symbol)).call(5)).to be false}
      it {expect(type(Symbol).and(type(Integer)).call('Hola')).to be false}
    end

    context 'or' do
      it {expect(type(Integer).or(type(Object)).call(5)).to be true}
      it {expect(type(Symbol).or(type(Integer)).call(5)).to be true}
      it {expect(type(Integer).or(type(Symbol)).call(5)).to be true}
      it {expect(type(Symbol).or(type(Integer)).call('Hola')).to be false}
    end

    context 'not' do
      it {expect(type(String).not.call('hola')).to be false}
      it {expect(type(String).not.call(5)).to be true}
    end

  end

  context 'Patterns' do
    it 'with suma' do
      x = [1, 2]
      result = x.with(list([:a, :b])) {a + b}
      expect(result).to eq 3
    end

    it 'with 1' do
      expect("hola".with(type(String), duck(:length, :==)) {"paso la prueba"}).to eq "paso la prueba"
    end

    it 'with 2' do
      expect("hola".with(duck(:length, :==)) {1 + 1}).to eq 2
    end

    it 'otherwise 1' do
      expect("cualquier cosa".otherwise {"paso la prueba"}).to eq "paso la prueba"
    end

    it 'otherwise 2' do
      expect("cualquier cosa".otherwise {20 * 3}).to eq 60
    end
  end

  context 'Matches' do
    it 'should match the first' do
      x = [1, 2, 3]
      result = matches?(x) do
        with(list([:a, val(2), duck(:+)])) {a + 2}
        with(list([1, 2, 3])) {'acá no llego - with'}
        otherwise {'acá no llego - otherwise'}
      end
      expect(result).to eq 3
    end

    it 'should match the second' do
      x = Object.new
      x.send(:define_singleton_method, :hola) {'hola'}
      result = matches?(x) do
        with(duck(:hola)) {'chau!'}
        with(type(Object)) {'acá no llego'}
      end
      expect(result).to eq 'chau!'
    end

    it 'should match otherwise' do
      x = 2
      result = matches?(x) do
        with(type(String)) {a + 2}
        with(list([1, 2, 3])) {'acá no llego'}
        otherwise {'acá si llego'}
      end
      expect(result).to eq 'acá si llego'
    end
  end
end
