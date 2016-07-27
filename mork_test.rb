require 'mork'
include Mork

# content = [
#   {
#     barcode: 1001,
#     header: { name: 'John Doe UI354320', title: 'Final exam', code:  '1001'}
#   },
#   {
#     barcode: 1002,
#     header: { name: 'Jane Roe UI354321', title: 'Final exam', code:  '1002'}
#   }
# ]

# sheet = SheetPDF.new content, 'layout.yml'
# sheet.save 'sheet.pdf'


s = SheetOMR.new 'resultado_ruim_2.jpg', 'layout.yml'
s.set_choices [5] * 120
s.marked_choices

# if s.set_choices [5] * 120
#   puts s.marked_choices
# else
#   puts "The sheet is not registered!"
# end

# s.overlay :mark, :marked
s.overlay :highlight, :marked
s.save 'marked_choices_ruim_2.jpg'


# def is_b_or_w(image, black_max_bgr=(40, 40, 40)):
#   # use this if you want to check channels are all basically equal
#   # I split this up into small steps to find out where your error is coming from
#   mean_bgr_float = np.mean(image, axis=(0,1))
#   mean_bgr_rounded = np.round(mean_bgr_float)
#   mean_bgr = mean_bgr_rounded.astype(np.uint8)
#   # use this if you just want a simple threshold for simple grayscale
#   # or if you want to use an HSV (V) measurement as in your example
#   mean_intensity = int(round(np.mean(image)))*1.1
#   return 'black' if np.all(mean_bgr < black_max_bgr) else 'white'

import cv2
import numpy as np
import matplotlib.pyplot as plt

img = cv2.imread('leitura_ruim.jpg')
output = img.copy()
original_img = img.copy()
rows,cols,ch = img.shape

marg = 0.15

regions = [
  [[1, np.floor(rows * marg/2)],
  [1, np.floor(cols * marg)]],
  [[np.floor(rows - (rows * marg/2)), rows],
  [1, np.floor(cols * marg)]],
  [[1, np.floor(rows * marg/2)],
  [np.floor(cols - (cols * marg)), cols]],
  [[np.floor(rows - (rows * marg/2)), rows],
  [np.floor(cols - (cols * marg)), cols]]
]

cc = []


# region = regions[2]
for region in regions:
  img = original_img[region[0][0]:region[0][1], region[1][0]:region[1][1]]
  gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
  plt.imshow(gray),plt.title('Input')
  plt.show()
  circles = cv2.HoughCircles(gray, cv2.cv.CV_HOUGH_GRADIENT, 1, 500, param1=30, param2=15, minRadius=35, maxRadius=50)
  circle = circles[0][0]
  # for circle in circles[0]:
  circleX = np.floor(region[1][0] + circle[0]).astype(int)
  circleY = np.floor(region[0][0] + circle[1]).astype(int)
  circleR = np.floor(circle[2]).astype(int)
  # circle_img = output[(circleY - circleR):(circleY + circleR), (circleX - circleR):(circleX + circleR)]
  # plt.imshow(circle_img)
  # plt.show()
  cc.append([circleX, circleY, circleR])
  cv2.circle(output, (circleX, circleY), circleR, (0, 255, 0), 4)
  cv2.rectangle(output, (circleX - 5, circleY - 5), (circleX + 5, circleY + 5), (0, 128, 255), -1)

plt.imshow(output)
plt.show()

c = cc[0]
p1 = [c[0]-c[2]*1.5, c[1]-c[2]*1.5]
c = cc[1]
p2 = [c[0]-c[2]*1.5, c[1]+c[2]*1.5]
c = cc[2]
p3 = [c[0]+c[2]*1.5, c[1]-c[2]*1.5]
c = cc[3]
p4 = [c[0]+c[2]*1.5, c[1]+c[2]*1.5]

# pts1 = np.float32([[cc[0][0]-cc[0][2], cc[0][1]-cc[0][2],[124,3969],[2826, 110],[2877,3991]])
pts1 = np.float32([p1,p2,p3,p4])
pts2 = np.float32([[0,0],[0,2*3900],[2*2700,0],[2*2700,2*3900]])

# # ensure at least some circles were found
# if circles is not None:
#   # convert the (x, y) coordinates and radius of the circles to integers
#   circles = np.round(circles[0, :]).astype("int")
 
#   # loop over the (x, y) coordinates and radius of the circles
#   for (x, y, r) in circles:
#     # draw the circle in the output image, then draw a rectangle
#     # corresponding to the center of the circle
#     cv2.circle(output, (x, y), r, (0, 255, 0), 4)
#     cv2.rectangle(output, (x - 5, y - 5), (x + 5, y + 5), (0, 128, 255), -1)
 
#   # show the output image
#   plt.imshow(output)
#   plt.show()

M = cv2.getPerspectiveTransform(pts1,pts2)

dst = cv2.warpPerspective(original_img,M,(2*2700,2*3900))


# plt.subplot(121),plt.imshow(img),plt.title('Input')
plt.subplot(122),plt.imshow(dst),plt.title('Output')
plt.show()

cv2.imwrite("resultado_ruim_2.jpg", dst)




import cv2
import numpy as np
import matplotlib.pyplot as plt

img = cv2.imread('circles.jpg')
rows,cols,ch = img.shape

output = img.copy()

gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
blur = cv2.blur(gray,(5,5))

circles = cv2.HoughCircles(blur, cv2.cv.CV_HOUGH_GRADIENT, 1.2, 100)

# ensure at least some circles were found
if circles is not None:
  # convert the (x, y) coordinates and radius of the circles to integers
  circles = np.round(circles[0, :]).astype("int")
 
  # loop over the (x, y) coordinates and radius of the circles
  for (x, y, r) in circles:
    # draw the circle in the output image, then draw a rectangle
    # corresponding to the center of the circle
    cv2.circle(output, (x, y), r, (0, 255, 0), 4)
    cv2.rectangle(output, (x - 5, y - 5), (x + 5, y + 5), (0, 128, 255), -1)
 
  # show the output image
  plt.imshow(output)
  plt.show()