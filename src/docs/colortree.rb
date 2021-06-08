Point  = Struct.new(:x, :y) do
    def +(rhs)
        Point.new(x + rhs.x, y + rhs.y)
    end
    def *(mul)
        Point.new(x * mul, y * mul)
    end
    def rotate(deg)
        rad = deg / 180.0 * Math::PI 
        Point.new(Math.cos(rad) * x - Math.sin(rad) * y, Math.sin(rad) * x + Math.cos(rad) * y)
    end
    def len()
        (x * x + y * y) ** 0.5
    end
end

Color = Struct.new(:r, :g, :b) do
    def +(rhs)
        Color.new(r + rhs.r, g + rhs.g, b + rhs.b)
    end

    def *(mul)
        Color.new(r * mul, g * mul, b * mul)
    end
end

Vertex = Struct.new(:xy, :rgb)
Triangle = Struct.new(:p1, :p2, :p3) do
    def points
        [*p1.xy, *p2.xy, *p3.xy]
    end
    def colors
        [*p1.rgb, 1,
         *p2.rgb, 1,
         *p3.rgb, 1]
    end
    def to_xml
        '<colortri points="' + points.join(" ") + '" colors="' + colors.join(" ") + '" />'
    end
end
Triangles = []
def gen(xy, dir, color1, color2, color3)
    STDERR.puts dir.len()
    return if dir.len() < 10
    3.times {
        xy2 = xy + dir * 2
        xy3 = xy + dir.rotate(90) * 0.5       
        xy4 = xy + dir * 2  + dir.rotate(90) * 0.5
        color4 = (color1 + color2 + color3) * (1.0 / 3)
        pt1 = Vertex.new(xy, color1)
        pt2 = Vertex.new(xy2, color2)
        pt3 = Vertex.new(xy3, color3)
        pt4 = Vertex.new(xy4, color4)
        Triangles.push (Triangle.new(pt1, pt2, pt3))
        Triangles.push (Triangle.new(pt3, pt2, pt4))
        gen(xy2, dir.rotate(-10) * 0.6, color1, color2, color4)
        gen(xy4, dir.rotate(10) * 0.6, color3, color4, color2)
        dir = dir.rotate(20)
    }
end

gen(Point.new(400, 720), Point.new(0, -120), Color.new(1, 0, 0), Color.new(0, 1, 0), Color.new(0, 0, 1))


puts <<-'EOF'
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
<svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px"
	 width="800.0px" height="800.0px" viewBox="0 0 800 800" enable-background="new 0 0 800 800"
	 xml:space="preserve">
EOF


Triangles.each {|tri|
    puts tri.to_xml
}

puts "
</svg>
"
